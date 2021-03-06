#!/usr/bin/env python3

import argparse
import subprocess

parser = argparse.ArgumentParser(
    description='Gives quotas from a BTRFS filesystem in a readable form'
)
parser.add_argument(
    '--unit', metavar='U', type=str,
    default='G',
    help='SI Unit, [B]ytes, K, M, G, T, P',
)
parser.add_argument(
    'mount_point', metavar='PATH', type=str,
    default='/',
    help='BTRFS mount point',
)
sys_args = parser.parse_args()
mount_point = sys_args.mount_point

multiplicator_lookup = ['B', 'K', 'M', 'G', 'T', 'P']

subvolume_data = dict()
cmd = ["btrfs",  "subvolume", "list", mount_point]
for line in subprocess.check_output(cmd).splitlines():
    args = str(line, encoding='utf8').split()
    subvolume_data[int(args[1])] = args[-1]

print("subvol\t\t\t\t\t\tgroup         total    unshared")
print("-" * 79)
cmd = ["btrfs", "qgroup", "show", "--raw", mount_point]
for line in subprocess.check_output(cmd).splitlines():
    args = str(line, encoding='utf8').split()

    try:
        subvolume_id = args[0].split('/')[-1]
        subvolume_name = subvolume_data[int(subvolume_id)]
    except:
        subvolume_name = "(unknown)"

    multiplicator = 1024 ** multiplicator_lookup.index(sys_args.unit)

    try:
        try:
            total = "%02.2f" % (float(args[1]) / multiplicator)
            unshared = "%02.2f" % (float(args[2]) / multiplicator)
        except ValueError:
            continue
        print("%s\t%s\t%s%s %s%s" % (
            subvolume_name.ljust(40),
            args[0],
            total.rjust(10), sys_args.unit,
            unshared.rjust(10), sys_args.unit,
        ))
    except IndexError:
        pass

