import os
import subprocess


def html_report(text,out_name):
    out_name = out_name.replace(".html",".Rmd")
    if os.path.isfile(out_name):
        os.remove(out_name)
    f = open(out_name,"w")
    f.write(text)
    f.close()

    command = "Rscript " + os.path.dirname(__file__) + "/render_markdown.R " + out_name
    subprocess.call(command, shell=True)


def unfold_list(str_start, what, str_end):
    if(isinstance(what,list)):
        return '\n'.join(map(lambda item: str_start+os.path.split(item)[1]+str_end, what))+'\n'
    else:
        return str_start+os.path.split(what)[1]+str_end+'\n'

