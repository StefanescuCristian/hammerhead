#include <linux/init.h>
#include <linux/module.h>
#include <linux/proc_fs.h>

static int
commit_read(char *buffer, char **start, off_t offset, int size, int *eof,
                void *data)
{
char *commit_str = "This kernel originates from commit aa8a30ed4ceeca58dc58a13e5a207093e3621349\n";
        int len = strlen(commit_str);
        if (size < len)
                return -EINVAL;
        if (offset != 0)
                return 0;
        strcpy(buffer, commit_str);

        return len;

}

static int __init
commit_init(void)
{
        if (create_proc_read_entry("commit", 0, NULL, commit_read,
                                    NULL) == 0) {
                printk(KERN_ERR
                       "Unable to register \"Commit\" proc file\n");
                return -ENOMEM;
        }

        return 0;
}

module_init(commit_init);

static void __exit
commit_exit(void)
{
        remove_proc_entry("commit", NULL);
}

module_exit(commit_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Stefanescu Cristian");
MODULE_DESCRIPTION("This displays the last pushed commit before building the kernel");
MODULE_VERSION("1.0");
