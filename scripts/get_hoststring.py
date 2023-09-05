#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Get hostname, convert using $tzvt_host_dict if set.

$tzvt_host_dict should have a json style dictionary.
"""
import os
import sys
import json
import subprocess as sub
import shlex as sh


def run(cmd, shell=False, check=False, get='all'):
    """Replicate getstatusoutput from subprocess.

    Params
    ------
    cmd : str or list
    shell : bool, optional
        Run as a shell, allows piping
    check : bool, optional
        Raise exception if command failed
    get : {'all', 'code', 'stdout', 'stderr'}, optional
        Control what is returned:
            - all: (code, stdout, stderr)
            - code/stdout/stderr: only that item
            - None: code only

    Returns
    -------
    output : str or tuple
        See get above. Default return value: (code, stdout, stderr)
    """
    get_options = ['all', 'stdout', 'stderr', 'code', None]
    if get not in get_options:
        raise ValueError(
            'get must be one of {0} is {1}'.format(get_options, get)
        )
    if not shell and isinstance(cmd, str):
        cmd = sh.split(cmd)
    if get != 'code' and get is not None:
        pp = sub.Popen(cmd, shell=shell, stdout=sub.PIPE, stderr=sub.PIPE)
        out, err = pp.communicate()
    else:
        pp = sub.Popen(cmd, shell=shell)
        pp.communicate()
    if not isinstance(out, str):
        out = out.decode()
    if not isinstance(err, str):
        err = err.decode()
    code = pp.returncode
    if check and code != 0:
        if get:
            sys.stderr.write(
                'Command failed\nSTDOUT:\n{0}\nSTDERR:\n{1}\n'
                .format(out, err)
            )
        raise sub.CalledProcessError(code, cmd)
    if get == 'all':
        return code, out.rstrip(), err.rstrip()
    elif get == 'stdout':
        return out.rstrip()
    elif get == 'stderr':
        return err.rstrip()
    return code


def get_hostname():
    """Get the hostname itself."""
    host_var = 'tzvt_host_dict'
    s = os.environ.get(host_var) if host_var in os.environ else '{}'
    s = s.replace("'", '"')

    try:
        host_dict = json.loads(s)
    except ValueError as err:
        sys.stderr.write(
            'Failed to parse {0} with the error:\n{1}\nNo hosts loaded\n'
            .format(host_var, str(err))
        )
        host_dict = {}

    if 'HOSTSHORT' in os.environ:
        host = os.environ.get('HOSTSHORT').split('.')[0]
    elif 'HOSTNAME' in os.environ:
        host = os.environ.get('HOSTNAME').split('.')[0]
    elif 'HOST' in os.environ:
        host = os.environ.get('HOST').split('.')[0]
    else:
        host = run('uname -n', get='stdout')

    host = host.strip()
    host = host_dict[host] if host in host_dict else host
    return host.strip()


def main():
    """Get host string for title."""
    host_str_var = 'tzvt_tmux_title_format_ssh'
    if len(sys.argv) > 1 and '--host-only' in sys.argv:
        return get_hostname()
    h = os.environ.get(host_str_var) if host_str_var in os.environ else '#h:#S:#T'
    if '#h' in h:
        host_str = h.replace('#h', get_hostname())
    else:
        host_str = h
    return host_str


if __name__ == '__main__' and '__file__' in globals():
    host_string = main()
    if not host_string:
        sys.exit(1)
    sys.stdout.write(host_string)
    sys.exit(0)
