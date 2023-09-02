bash-script-template
====================

Copied from https://github.com/ralish/bash-script-template But change to getopts .....

First reduce it to a short template that I will easy use. If I need more I come back to the original. :-)

Use a link or rename the script to execute command with the extension like template-d for option demo..... 

# Think about? 
* -h -? (--help) stops the command no command execution give help.
* If i set the -e exit in a script if a test get zero 0? Is this good for programming? 
* arguments are normally allways execute in the same order!
* long  command-line arguments example: --help as alternative possible? 
* loggger
* getopts
* echo "test" > /tmp/log$$

Dos2Linux convert text files:
tr -d '\015' <DOS-file >UNIX-file
vim file.txt -c "set ff=unix" -c ":wq"

License
-------

All content is licensed under the terms of [The MIT License](LICENSE).
