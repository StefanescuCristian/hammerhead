/*
 * Dynamic Hotplug for mako / hammerhead
 *
 * Copyright (C) 2013 Stratos Karafotis <stratosk@semaphore.gr> (dyn_hotplug for mako)
 *
 * Copyright (C) 2014 engstk <eng.stk@sapo.pt> (hammerhead port, fixes and changes to blu_plug) 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/cpu.h>
#include <linux/workqueue.h>
#include <linux/sched.h>
#include <linux/timer.h>
#include <linux/lcd_notify.h>
#include <linux/cpufreq.h>
#include <linux/delay.h>
#include <linux/slab.h>

#define INIT_DELAY		(60 * HZ) /* Initial delay to 60 sec */
#define DELAY			(HZ / 2)
#define UP_THRESHOLD		(25)
#define MIN_ONLINE		(2)
#define MAX_ONLINE		(4)
#define DEF_DOWN_TIMER_CNT	(10)	/* 5 secs */
#define DEF_UP_TIMER_CNT	(2)	/* 1 sec */

static int enabled;
static unsigned int up_threshold;
static unsigned int delay;
static unsigned int min_online;
static unsigned int max_online;
static unsigned int down_timer;
static unsigned int up_timer;
static unsigned int down_timer_cnt;
static unsigned int up_timer_cnt;
static unsigned int saved_min_online;

static struct delayed_work dyn_work;
static struct workqueue_struct *dyn_workq;
static struct work_struct suspend, resume;
static struct notifier_block notify;


/*
 * Bring online each possible CPU up to max_online threshold if lim is true or
 * up to num_possible_cpus if lim is false
 */
static inline void up_all(bool lim)
{
	unsigned int cpu;
	unsigned int max = (lim ? max_online : num_possible_cpus());

	for_each_possible_cpu(cpu)
		if (cpu_is_offline(cpu) && num_online_cpus() < max)
			cpu_up(cpu);

	down_timer = 0;
}

/* Bring offline each possible CPU down to min_online threshold */
static inline void down_all(void)
{
	unsigned int cpu;

	for_each_online_cpu(cpu)
		if (cpu && num_online_cpus() > min_online)
			cpu_down(cpu);
}

/* Iterate through possible CPUs and bring online the first found offline one */
static inline void up_one(void)
{
	unsigned int cpu;

	/* All CPUs are online, return */
	if (num_online_cpus() == max_online)
		goto out;

	cpu = cpumask_next_zero(0, cpu_online_mask);
	cpu_up(cpu);
out:
	down_timer = 0;
	up_timer = 0;
}

/* Iterate through online CPUs and bring online the first one */
static inline void down_one(void)
{
	unsigned int cpu;
	unsigned int l_cpu = 0;
	unsigned int l_freq = ~0;

	/* Min online CPUs, return */
	if (num_online_cpus() == min_online)
		goto out;

	for_each_online_cpu(cpu)
		if (cpu) {
			unsigned int cur = cpufreq_quick_get(cpu);

			if (l_freq > cur) {
				l_freq = cur;
				l_cpu = cpu;
			}
		}

	cpu_down(l_cpu);
out:
	down_timer = 0;
	up_timer = 0;
}

/*
 * Every DELAY, check the average load of online CPUs. If the average load
 * is above up_threshold bring online one more CPU if up_timer has expired.
 * If the average load is below up_threshold offline one more CPU if the
 * down_timer has expired.
 */
static __cpuinit void load_timer(struct work_struct *work)
{
	unsigned int cpu, max_rate;
	unsigned int avg_load = 0;

	if (down_timer < down_timer_cnt)
		down_timer++;

	if (up_timer < up_timer_cnt)
		up_timer++;
		
	max_rate = cpufreq_quick_get_max(cpu);
	
	for_each_online_cpu(cpu)
		avg_load += cpufreq_quick_get(cpu);

	avg_load = (int)(((avg_load/num_online_cpus())/max_rate)*100);
	pr_debug("%s: avg_load: %u, num_online_cpus: %u, down_timer: %u\n", __func__, avg_load, num_online_cpus(), down_timer);

	if (avg_load >= up_threshold && up_timer >= up_timer_cnt)
		up_one();
	else if (down_timer >= down_timer_cnt)
		down_one();

	queue_delayed_work_on(0, dyn_workq, &dyn_work, delay);
}

static void dyn_hp_enable(void)
{
	queue_delayed_work_on(0, dyn_workq, &dyn_work, delay);
}

static void dyn_hp_disable(void)
{
	cancel_delayed_work(&dyn_work);
	flush_scheduled_work();

	/* Driver is disabled bring online all CPUs unconditionally */
	up_all(false);
}

/* On suspend bring offline all cores except cpu0*/
static void dyn_lcd_suspend(struct work_struct *work)
{
	pr_debug("%s: num_online_cpus: %u\n", __func__, num_online_cpus());

	saved_min_online = min_online;
	min_online = 1;
}

/* On resume bring online all CPUs to prevent lags */
static __cpuinit void dyn_lcd_resume(struct work_struct *work)
{
	pr_debug("%s: num_online_cpus: %u\n", __func__, num_online_cpus());

	min_online = saved_min_online;
	up_all(true);
}

static int __cpuinit lcd_notifier_callback(struct notifier_block *this, unsigned long event, void *data)
{
	switch (event) {
	case LCD_EVENT_ON_END:
	case LCD_EVENT_OFF_START:
		break;
	case LCD_EVENT_ON_START:
		queue_work_on(0, dyn_workq, &resume);
		break;
	case LCD_EVENT_OFF_END:
		queue_work_on(0, dyn_workq, &suspend);
		break;
	default:
		break;
	}

	return NOTIFY_OK;
}

/******************** Module parameters *********************/

/* enabled */
static __cpuinit int set_enabled(const char *val, const struct kernel_param *kp)
{
	int ret = 0;

	ret = param_set_bool(val, kp);
	if (!enabled)
		dyn_hp_disable();
	else
		dyn_hp_enable();

	pr_info("%s: enabled = %d\n", __func__, enabled);
	
	return ret;
}

static struct kernel_param_ops enabled_ops = {
	.set = set_enabled,
	.get = param_get_bool,
};

module_param_cb(enabled, &enabled_ops, &enabled, 0644);
MODULE_PARM_DESC(enabled, "control dyn_hotplug");

/* up_threshold */
static int set_up_threshold(const char *val, const struct kernel_param *kp)
{
	int ret = 0;
	unsigned int i;

	ret = kstrtouint(val, 10, &i);
	if (ret)
		return -EINVAL;
	if (i < 1 || i > 100)
		return -EINVAL;

	ret = param_set_uint(val, kp);

	return ret;
}

static struct kernel_param_ops up_threshold_ops = {
	.set = set_up_threshold,
	.get = param_get_uint,
};

module_param_cb(up_threshold, &up_threshold_ops, &up_threshold, 0644);

/* min_online */
static __cpuinit int set_min_online(const char *val, const struct kernel_param *kp)
{
	int ret = 0;
	unsigned int i;

	ret = kstrtouint(val, 10, &i);
	if (ret)
		return -EINVAL;
	if (i < 1 || i > max_online || i > num_possible_cpus())
		return -EINVAL;

	ret = param_set_uint(val, kp);
	
	if (ret == 0) {
		saved_min_online = min_online;
		if (enabled)
			up_all(true);
	}
	
	return ret;
}

static struct kernel_param_ops min_online_ops = {
	.set = set_min_online,
	.get = param_get_uint,
};

module_param_cb(min_online, &min_online_ops, &min_online, 0644);

/* max_online */
static __cpuinit int set_max_online(const char *val, const struct kernel_param *kp)
{
	int ret = 0;
	unsigned int i;

	ret = kstrtouint(val, 10, &i);
	if (ret)
		return -EINVAL;
	if (i < 1 || i < min_online || i > num_possible_cpus())
		return -EINVAL;

	ret = param_set_uint(val, kp);
	
	if (ret == 0) {
		if (enabled) {
			down_all();
			up_all(true);
		}
	}
	
	return ret;
}

static struct kernel_param_ops max_online_ops = {
	.set = set_max_online,
	.get = param_get_uint,
};

module_param_cb(max_online, &max_online_ops, &max_online, 0644);

/* down_timer_cnt */
static int set_down_timer_cnt(const char *val, const struct kernel_param *kp)
{
	int ret = 0;
	unsigned int i;

	ret = kstrtouint(val, 10, &i);
	if (ret)
		return -EINVAL;
	if (i < 1 || i > 50)
		return -EINVAL;

	ret = param_set_uint(val, kp);
	
	return ret;
}

static struct kernel_param_ops down_timer_cnt_ops = {
	.set = set_down_timer_cnt,
	.get = param_get_uint,
};

module_param_cb(down_timer_cnt, &down_timer_cnt_ops, &down_timer_cnt, 0644);

/* up_timer_cnt */
static int set_up_timer_cnt(const char *val, const struct kernel_param *kp)
{
	int ret = 0;
	unsigned int i;

	ret = kstrtouint(val, 10, &i);
	if (ret)
		return -EINVAL;
	if (i < 1 || i > 50)
		return -EINVAL;

	ret = param_set_uint(val, kp);

	return ret;
}

static struct kernel_param_ops up_timer_cnt_ops = {
	.set = set_up_timer_cnt,
	.get = param_get_uint,
};

module_param_cb(up_timer_cnt, &up_timer_cnt_ops, &up_timer_cnt, 0644);

/***************** end of module parameters *****************/

static int __init dyn_hp_init(void)
{
	delay = DELAY;
	up_threshold = UP_THRESHOLD;
	min_online = MIN_ONLINE;
	max_online = MAX_ONLINE;
	down_timer_cnt = DEF_DOWN_TIMER_CNT;
	up_timer_cnt = DEF_UP_TIMER_CNT;
	
	notify.notifier_call = lcd_notifier_callback;
	if (lcd_register_client(&notify) != 0)
		pr_warn("lcd client register error\n");
	
	dyn_workq = alloc_workqueue("dyn_hotplug_workqueue", WQ_FREEZABLE, 1);
	if (!dyn_workq)
		return -ENOMEM;

	INIT_WORK(&resume, dyn_lcd_resume);
	INIT_WORK(&suspend, dyn_lcd_suspend);
	INIT_DELAYED_WORK(&dyn_work, load_timer);
	queue_delayed_work_on(0, dyn_workq, &dyn_work, INIT_DELAY);

	pr_info("%s: activated\n", __func__);

	return 0;
}

static void __exit dyn_hp_exit(void)
{
	cancel_delayed_work(&dyn_work);
	flush_scheduled_work();
	destroy_workqueue(dyn_workq);
	
	pr_info("%s: deactivated\n", __func__);
}

MODULE_AUTHOR("Stratos Karafotis <stratosk@semaphore.gr");
MODULE_AUTHOR("engstk <eng.stk@sapo.pt>");
MODULE_DESCRIPTION("'dyn_hotplug' - A dynamic hotplug driver for mako / hammerhead (blu_plug)");
MODULE_LICENSE("GPL");

late_initcall(dyn_hp_init);
module_exit(dyn_hp_exit);
