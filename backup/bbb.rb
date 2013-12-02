#!/usr/bin/env ruby
# encoding: utf-8
def parse_trinity(result, src_dir)
  begin_b_pat = /\[[^\]]*\]\sBUG:\s.*/
  begin_w_pat = /\[[^\]]*\]\sWARNING:\s.*/
  end_pat = /\[\send\strace\s.*\s\]/
  
  beginning = false
  title = ""

  parsed_result = []
  index = {}
  item = {}
  
  result.each do |r|
    endm = end_pat.match(r)
    if(endm)
      parsed_result.push(item)
      beginning = false
    end
    
    if(beginning)
      item[:toolDescription] = item[:toolDescription] + r
      item[:toolDescription] = item[:toolDescription] + "\n"
    end

    beginm = begin_b_pat.match(r)
    if(beginm)
      beginning = true
      item = {
        :file => "",
        :line => "",
        :target => "Linux Kernel",
        :opensource => 1,
        :toolDescription => r,
        :title => "Bug from Trinity",
        :bugType => ""
      }
    end
    beginm = begin_w_pat.match(r)
    if(beginm)
      beginning = true
      item = {
        :file => "",
        :line => "",
        :target => "Linux Kernel",
        :opensource => 1,
        :toolDescription => r,
        :title => "Warning from Trinity",
        :bugType => ""
      }
    end
    
  end
  parsed_result
end
 
 result = "
[ 95.241079] WARNING: at lib/idr.c:678 idr_find_slowpath+0xa0/0xb0()
[ 95.241402] Hardware name: Bochs
[ 95.241592] Modules linked in:
[ 95.242374] Pid: 3276, comm: trinity-main Not tainted 3.9.0-rc1+ #1
[ 95.242557] Call Trace:
[ 95.242970] [] warn_slowpath_common+0x6d/0xa0
[ 95.243267] [] ? idr_find_slowpath+0xa0/0xb0
[ 95.243412] [] ? idr_find_slowpath+0xa0/0xb0
[ 95.243556] [] warn_slowpath_null+0x1d/0×20
[ 95.243694] [] idr_find_slowpath+0xa0/0xb0
[ 95.243830] [] perf_init_event+0×35/0xc0
[ 95.243962] [] perf_event_alloc+0x2d8/0×440
[ 95.244163] [] sys_perf_event_open+0x32d/0×860
[ 95.244389] [] ? __do_page_fault+0×470/0×470
[ 95.244558] [] sysenter_do_call+0×12/0×22
[ 95.244778] —[ end trace c303fd4ec49b61f7 ]—
[main] fd[9] = perf
[main] fd[10] = perf
[main] fd[11] = perf
[main] fd[12] = perf
[main] fd[13] = perf
[main] fd[14] = perf
[main] fd[15] = perf
[main] fd[16] = perf
[main] fd[17] = perf
[main] fd[18] = perf
[main] fd[19] = epoll
[main] fd[20] = epoll
[main] fd[21] = epoll
[main] fd[22] = epoll
[main] fd[23] = epoll
[main] fd[24] = epoll
[main] fd[25] = epoll
[main] fd[26] = epoll
[main] fd[27] = epoll
[main] fd[28] = epoll
[main] fd[29] = eventfd
[main] fd[30] = eventfd
[main] fd[31] = eventfd
[main] fd[32] = eventfd
[main] fd[33] = eventfd
[main] fd[34] = eventfd
[main] fd[35] = eventfd
[main] fd[36] = eventfd
[main] Generating file descriptors
[main] Added 48 filenames from /tmp/include
[main] fd[37] = /tmp/include/arch-mips.h (read-write)
[main] fd[38] = /tmp/include/types.h (read-write)
[main] fd[39] = /tmp/include/syscalls-arm.h (read-write)
[main] fd[40] = /tmp/include/syscalls-arm.h (read-write)
[main] fd[41] = /tmp/include/syscalls-mips.h (read-write)
[main] fd[42] = /tmp/include/pids.h (read-write)
[main] fd[43] = /tmp/include/arch-sparc.h (read-write)
[main] fd[44] = /tmp/include/perf.h (read-write)
[main] fd[45] = /tmp/include/syscalls-arm.h (read-write)
[main] fd[46] = /tmp/include/params.h (read-write)
[main] fd[47] = /tmp/include/syscall.h (read-write)
[main] fd[48] = /tmp/include/perf_event.h (read-write)
[main] fd[49] = /tmp/include/arch-mips.h (read-write)
[main] fd[50] = /tmp/include/syscalls-s390.h (read-write)
[main] fd[51] = /tmp/include/arch-sh.h (read-write)
[main] fd[52] = /tmp/include/syscalls-arm.h (read-write)
[main] fd[53] = /tmp/include/signals.h (read-write)
[main] fd[54] = /tmp/include/arch-s390.h (read-write)
[main] fd[55] = /tmp/include/list.h (read-write)
[main] fd[56] = /tmp/include/arch-i386.h (read-write)
[main] fd[57] = /tmp/include/arch-arm.h (read-write)
[main] fd[58] = /tmp/include/syscall.h (read-write)
[main] fd[59] = /tmp/include/log.h (read-write)
[main] fd[60] = /tmp/include/arch-mips.h (read-write)
[main] fd[61] = /tmp/include/arch-sparc.h (read-write)
[main] fd[62] = /tmp/include/syscalls-s390x.h (read-write)
[main] fd[63] = /tmp/include/perf.h (read-write)
[main] fd[64] = /tmp/include/maps.h (read-write)
[main] fd[65] = /tmp/include/arch.h (read-write)
[main] fd[66] = /tmp/include/syscalls-aarch64.h (read-write)
[main] fd[67] = /tmp/include/arch.h (read-write)
[main] fd[68] = /tmp/include/signals.h (read-write)
[main] fd[69] = /tmp/include/syscalls-s390x.h (read-write)
[main] fd[70] = /tmp/include/signals.h (read-write)
[main] fd[71] = /tmp/include/arch-i386.h (read-write)
[main] fd[72] = /tmp/include (read-only)
[main] fd[73] = /tmp/include/exit.h (read-write)
[main] fd[74] = /tmp/include/random.h (read-write)
[main] fd[75] = /tmp/include/syscalls-arm.h (read-write)
[main] fd[76] = /tmp/include/arch-ppc.h (read-write)
[main] fd[77] = /tmp/include/trinity.h (read-write)
[main] fd[78] = /tmp/include/arch-i386.h (read-write)
[main] fd[79] = /tmp/include/arch.h (read-write)
[main] fd[80] = /tmp/include (read-only)
[main] fd[81] = /tmp/include/compat.h (read-write)
[main] fd[82] = /tmp/include/perf.h (read-write)
[main] fd[83] = /tmp/include/syscalls-s390x.h (read-write)
[main] fd[84] = /tmp/include/syscalls-i386.h (read-write)
[child0:3277] [0] newfstat[0m(fd=[1;36m[0m34[0m, statbuf=[0m0[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [1] mremap[0m(addr=[1;36m0xc0100000[0m[0m, old_len=[0m0[0m[0m, new_len=[1;36m168[0m[0m, flags=[1;36m1[0m[0m, new_addr=[1;36m0xc0100224[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [2] listxattr[0m(pathname=[1;36m\"/tmp/include/pids.h\"[0m, list=[1;36m4[0m[0m, size=[1;36m8[0m[0m) [1;32m= 0[0m
[child0:3277] [3] chown[0m(filename=[1;36m\"/tmp/include/random.h\"[0m, user=[1;36m0x831d6341[0m[0m, group=[1;36m0xe2000080[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [4] getuid[0m([0m) [1;32m= 1000[0m
[child0:3277] [5] mmap_pgoff[0m(addr=[1;36m1[0m[0m, len=[1;36m0xc840[0m[0m, prot=[1;36m12[0m[0m, flags=[1;36m0x14122[0m[0m, fd=[1;36m[0m5[0m, pgoff=[1;36m0x5100[0m[0m) [1;32m= 0xb6186000[0m
[child0:3277] [6] rt_sigsuspend[0m(unewset=[0m1[0m[0m, sigsetsize=[1;36m0xedbff7ef[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [7] llistxattr[0m(pathname=[1;36m\"/tmp/include\"[0m, list=[1;36m0x87a3000[0m[page_0xff][0m, size=[1;36m117[0m[0m) [1;32m= 0[0m
[child0:3277] [8] move_pages[0m(pid=[1;36m0[0m[0m, nr_pages=[1;36m591[0m[0m, pages=[1;36m0x8cbf440[0m[0m, nodes=[1;36m0x879f5f8[0m[0m, status=[1;36m0x87aa008[0m[0m, flags=[1;36m0[0m[0m) [1;31m= -1 (Function not implemented)[0m
[child0:3277] move_pages (317) returned ENOSYS, marking as inactive.
[child0:3277] [9] fremovexattr[0m(fd=[1;36m[0m5[0m, name=[1;36m4[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [10] sendfile[0m(out_fd=[1;36m[0m8[0m, in_fd=[1;36m[0m8[0m, offset=[1;36m1[0m[0m, count=[1;36m9[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [11] umount[0m(name=[1;36m\"/tmp/include/arch-arm.h\"[0m, flags=[1;36m6[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [12] iopl[0m(level=[1;36m0xffff5b[0m[0m, regs=[1;36m0[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [13] capget[0m(header=[1;36m0x94000040[0m[0m, dataptr=[1;36m0x80040000[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [14] epoll_create[0m(size=[1;36m1024[0m[0m) [1;32m= 85[0m
[child0:3277] [15] getppid[0m([0m) [1;32m= 3276[0m
[child0:3277] [16] chown[0m(filename=[1;36m\"%d%d%d%s%d%s%s%s%s%s%s%d%d%/\"[0m, user=[1;36m0xc000ffff[0m[0m, group=[1;36m0xffffffff[0m[0m) [1;31m= -1 (No such file or directory)[0m
[child0:3277] [17] fstatat64[0m(dfd=[1;36m[0m8[0m, filename=[1;36m\"/tmp/include/compat.h\"[0m, statbuf=[1;36m0xc0100220[0m[0m, flag=[1;36m0xff000000[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [18] lchown[0m(filename=[1;36m\"/tmp/include/syscalls-x86_64.h\"[0m, user=[1;36m0xfff9275f[0m[0m, group=[1;36m0xe848be4d[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [19] geteuid[0m([0m) [1;32m= 1000[0m
[child0:3277] [20] getpgrp[0m([0m) [1;32m= 3232[0m
[child0:3277] [21] renameat[0m(olddfd=[1;36m[0m20[0m, oldname=[1;36m0x87a3000[0m[page_0xff][0m, newdfd=[1;36m[0m8[0m, newname=[1;36m0x87a3004[0m[0m) [1;31m= -1 (File name too long)[0m
[child0:3277] [22] kexec_load[0m(entry=[1;36m4[0m[0m, nr_segments=[1;36m111[0m[0m, segments=[1;36m0x87ab000[0m[page_allocs][0m, flags=[1;36m2[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [23] ppoll[0m(ufds=[1;36m1[0m[0m, nfds=[1;36m0[0m[0m, tsp=[1;36m5[0m[0m, sigmask=[1;36m0x8f116c8[0m[0m, sigsetsize=[1;36m0x80210000[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [24] perf_event_open[0m(attr_uptr=[1;36m0x87a8000[0m[page_rand][0m, pid=[1;36m[0m8[0m, cpu=[1;36m0[0m[0m, group_fd=[1;36m[0m-1[0m, flags=[1;36m0xffffffff[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [25] lstat64[0m(filename=[1;36m\"/tmp/include/syscalls-sparc.h\"[0m, statbuf=[1;36m0xf686195d[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [26] bdflush[0m(func=[1;36m0xc00b1b1[0m[0m, data=[1;36m4[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [27] mknodat[0m(dfd=[1;36m[0m12[0m, filename=[1;36m\"/tmp/include/child.h\"[0m, mode=[1;36m0xfd79feff[0m[0m, dev=[1;36m0x80001212[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [28] ftruncate64[0m(fd=[1;36m[0m58[0m, length=[1;36m0x20000[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [29] truncate[0m(path=[1;36m\"/tmp/include/arch-alpha.h\"[0m, length=[1;36m255[0m[0m) [1;32m= 0[0m
[child0:3277] [30] vm86[0m(cmd=[1;36m0xefffffff[0m[0m, arg=[1;36m0xffffff03[0m[0m, regs=[1;36m0x87ab000[0m[page_allocs][0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [31] mknod[0m(filename=[1;36m\"/tmp/include/arch-ppc.h\"[0m, mode=[1;36m[0m3005[0m, dev=[1;36m0xf48fae36[0m[0m) [1;31m= -1 (File exists)[0m
[child0:3277] [32] clock_settime[0m(which_clock=[1;36m0xba5b028f[0m[0m, tp=[1;36m1[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [33] getxattr[0m(pathname=[1;36m\"/tmp/include/exit.h\"[0m, name=[1;36m0xc0100220[0m[0m, value=[1;36m0xc0100220[0m[0m, size=[1;36m0[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [34] ioprio_get[0m(which=[1;36m0x79787878[0m[0m, who=[1;36m0xf1e7eed0[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [35] timerfd_gettime[0m(ufd=[1;36m[0m12[0m, otmr=[1;36m0[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [36] truncate[0m(path=[1;36m\"/tmp/include/trinity.h\"[0m, length=[1;36m0xfeff[0m[0m) [1;32m= 0[0m
[child0:3277] [37] olduname[0m(name=[1;36m0[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [38] setrlimit[0m(resource=[0m0[0m[0m, rlim=[1;36m0xbfb7b719[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [39] chown[0m(filename=[1;36m\"/tmp/include\"[0m, user=[1;36m0xfa91bc6c[0m[0m, group=[1;36m0x87ffffff[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [40] write[0m(fd=[1;36m[0m33[0m, buf=[1;36m0x87a8000[0m[page_rand][0m, count=[1;36m916[0m[0m) [1;32m= 8[0m
[child0:3277] [41] unlinkat[0m(dfd=[1;36m[0m12[0m, pathname=[1;36m\"/tmp/include/maps.h\"[0m, flag=[1;36m0xffffff85[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [42] personality[0m(personality=[1;36m0xfddb9380[0m[0m) [1;32m= 0[0m
[child0:3277] [43] old_readdir[0m(fd=[1;36m[0m21[0m, dirent=[1;36m0x8f136d0[0m[0m, count=[1;36m0xff7f[0m[0m) [1;31m= -1 (Not a directory)[0m
[child0:3277] [44] statfs[0m(pathname=[1;36m\"/tmp/include/signals.h\"[0m, buf=[1;36m0x87ab000[0m[page_allocs][0m) [1;32m= 0[0m
[child0:3277] [45] futimesat[0m(dfd=[1;36m[0m12[0m, filename=[1;36m\"/tmp/include/arch-arm.h\"[0m, utimes=[1;36m0xc0100220[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [46] mmap_pgoff[0m(addr=[1;36m4[0m[0m, len=[1;36m239[0m[0m, prot=[1;36m4[0m[0m, flags=[1;36m0x3f002[0m[0m, fd=[1;36m[0m12[0m, pgoff=[1;36m0[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [47] io_setup[0m(nr_events=[1;36m0x910000ff[0m[0m, ctxp=[1;36m0x87a3000[0m[page_0xff][0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [48] getpgid[0m(pid=[1;36m[0m3277[0m) [1;32m= 3232[0m
[child0:3277] [49] old_readdir[0m(fd=[1;36m[0m12[0m, dirent=[1;36m4[0m[0m, count=[1;36m133[0m[0m) [1;31m= -1 (Not a directory)[0m
[child0:3277] [50] perf_event_open[0m(attr_uptr=[1;36m0x87a8000[0m[page_rand][0m, pid=[1;36m[0m0[0m, cpu=[1;36m0[0m[0m, group_fd=[1;36m[0m49[0m, flags=[1;36m0xffff15b3[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [51] getrusage[0m(who=[1;36m0x1000ffd7[0m[0m, ru=[1;36m0x8f156d8[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [52] set_robust_list[0m(head=[1;36m4[0m[0m, len=[1;36m12[0m[0m) [1;32m= 0[0m
[child0:3277] [53] open[0m(filename=[1;36m\"/tmp/include/list.h\"[0m, flags=[1;36m0x39d902[0m[0m, mode=[1;36m[0m0[0m) [1;31m= -1 (Not a directory)[0m
[child0:3277] [54] fcntl[0m(fd=[1;36m[0m50[0m, cmd=[1;36m1032[0m[0m, arg=[1;36m0x92000000[0m[0m) [1;31m= -1 (Bad file descriptor)[0m
[child0:3277] [55] setreuid[0m(ruid=[1;36m0xfbffffff[0m[0m, euid=[1;36m0xffffffff[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [56] setrlimit[0m(resource=[1;36m0[0m[0m, rlim=[1;36m0xfffffffe[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [57] utimensat[0m(dfd=[1;36m[0m5[0m, filename=[1;36m\"/tmp/include/syscalls-s390x.h\"[0m, utimes=[1;36m4[0m[0m, flags=[1;36m256[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [58] sethostname[0m(name=[1;36m0xc0100220[0m[0m, len=[1;36m7839[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [59] getxattr[0m(pathname=[1;36m\"/tmp/include/arch-sh.h\"[0m, name=[1;36m0[0m[0m, value=[1;36m0x87abfff[0m[0m, size=[1;36m0xf0f7[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [60] sched_get_priority_min[0m(policy=[1;36m0x9ff42444[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [61] timer_delete[0m(timer_id=[1;36m0xa97f002e[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [62] lstat64[0m(filename=[1;36m\"/tmp/include/syscalls-arm.h\"[0m, statbuf=[1;36m4[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [63] rt_tgsigqueueinfo[0m(tgid=[1;36m0xff4b38e5[0m[0m, pid=[1;36m[0m3277[0m, sig=[1;36m0xff00000b[0m[0m, uinfo=[1;36m4[0m[0m) [1;31m= -1 (Bad address)[0m
[child0:3277] [64] setfsgid[0m(gid=[1;36m0xffff85b1[0m[0m) [1;32m= 1000[0m
[child0:3277] [65] getuid16[0m([0m) [1;32m= 1000[0m
[child0:3277] [66] read[0m(fd=[1;36m[0m35[0m, buf=[1;36m0x87a8000[0m[page_rand][0m, count=[1;36m1947[0m[0m) [1;32m= 8[0m
[child0:3277] [67] sched_getscheduler[0m(pid=[1;36m[0m0[0m) [1;32m= 0[0m
[child0:3277] [68] getdents[0m(fd=[1;36m[0m50[0m, dirent=[1;36m0[0m[0m, count=[1;36m0xdedb[0m[0m) [1;31m= -1 (Not a directory)[0m
[child0:3277] [69] sched_getparam[0m(pid=[1;36m[0m0[0m, param=[1;36m0x87ab000[0m[page_allocs][0m) [1;32m= 0[0m
[child0:3277] [70] writev[0m(fd=[1;36m[0m50[0m, vec=[1;36m0x879ff38[0m[0m, vlen=[1;36m3[0m[0m) [1;32m= 0x3000[0m
[child0:3277] [71] setgid16[0m(gid=[1;36m0xff7dffff[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [72] get_robust_list[0m(pid=[1;36m[0m0[0m, head_ptr=[1;36m0x87ab000[0m[page_allocs][0m, len_ptr=[1;36m0x87a3000[0m[page_0xff][0m) [1;32m= 0[0m
[child0:3277] [73] dup3[0m(oldfd=[1;36m[0m50[0m, newfd=[1;36m[0m50[0m, flags=[1;36m0[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [74] init_module[0m(umod=[1;36m0x87a8000[0m[page_rand][0m, len=[1;36m0[0m[0m, uargs=[1;36m0x87a8004[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [75] setresgid[0m(rgid=[1;36m0xefbd7afb[0m[0m, egid=[1;36m0xcb3aa7c1[0m[0m, sgid=[1;36m0xcbcbcbcb[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [76] truncate[0m(path=[1;36m\"/tmp/include/arch-sh.h\"[0m, length=[1;36m0[0m[0m) [1;32m= 0[0m
[child0:3277] [77] epoll_create1[0m(flags=[1;36m0x80000[0m[0m) [1;32m= 86[0m
[child0:3277] [78] openat[0m(dfd=[1;36m[0m28[0m, filename=[1;36m\"/tmp/include/signals.h\"[0m, flags=[1;36m0xf400[0m[0m, mode=[1;36m[0m7[0m) [1;32m= 87[0m
[child0:3277] [79] sigaltstack[0m(uss=[1;36m0x8f1a6f8[0m[0m, uoss=[1;36m0x87a8000[0m[page_rand][0m, regs=[1;36m0x87a8001[0m[0m) [1;31m= -1 (Cannot allocate memory)[0m
[child0:3277] [80] setresuid16[0m(ruid=[1;36m0xffffff00[0m[0m, euid=[1;36m0x91faf2d5[0m[0m, suid=[1;36m0x90004838[0m[0m) [1;31m= -1 (Operation not permitted)[0m
[child0:3277] [81] sched_getaffinity[0m(pid=[1;36m[0m3277[0m, len=[1;36m6[0m[0m, user_mask_ptr=[1;36m0xc0100220[0m[0m) [1;31m= -1 (Invalid argument)[0m
[child0:3277] [82] inotify_init1[0m(flags=[1;36m0x80000[0m[0m) [1;32m= 88[0m
[watchdog] Watchdog is alive. (pid:3275)
[watchdog] kernel became tainted! (512/0) Last seed was 1424952196
[child0:3277] [83] vmsplice[0m(fd=[1;36m[0m5[0m, iov=[1;36m0x87a73b8[0m[0m, nr_segs=[1;36m935[0m[0m, flags=[1;36m9[0m[0m) [child0:3277]
[child0:3277] child exiting.
Bailing main loop. Exit reason: kernel became tainted.
[watchdog] [3275] Watchdog exiting
[init]
Ran 84 syscalls. Successes: 26 Failures: 57
2 trinity test
Trinity v1.3pre Dave Jones
Done parsing arguments.
Marking all syscalls as enabled.
[init] Enabled 351 syscalls. Disabled 0 syscalls.
[init] shm is at 0xb7501000
[init] page_zeros @ 0x8aa0000
[init] page_0xff @ 0x8aa3000
[init] page_rand @ 0x8aa8000
[init] page_allocs @ 0x8aab000
[init] mapping[0]: (zeropage PROT_READ | PROT_WRITE) 0xb72e3000 (2097152 bytes)
[init] mapping[1]: (zeropage PROT_READ) 0xb70e3000 (2097152 bytes)
[init] mapping[2]: (zeropage PROT_WRITE) 0xb6ee3000 (2097152 bytes)
[init] Added /dev/zero mappings.
[init] There are 3 entries in the map table
[init] start: 0xb72e3000 name: /dev/zero(PROT_READ | PROT_WRITE)
[init] start: 0xb70e3000 name: /dev/zero(PROT_READ)
[init] start: 0xb6ee3000 name: /dev/zero(PROT_WRITE)
[init] Parsed 27 char devices, 22 block devices, 12 misc devices.
[init] Using pid_max = 32768
[init] Kernel was tainted on startup. Will ignore flags that are already set.
[init] Started watchdog process, PID is 3281
[main] Main thread is alive.
[main] fd[5] = pipe
[main] fd[6] = pipe
[main] fd[7] = pipe
[main] fd[8] = pipe
[main] fd[9] = perf
[main] fd[10] = perf
[main] fd[11] = perf
[main] fd[12] = perf
[main] fd[13] = perf
[main] fd[14] = perf
[ 98.474064] BUG: unable to handle kernel paging request at e1a89e20
[ 98.474162] IP: [] perf_swevent_init+0x6e/0×130
[ 98.474162] *pde = 00000000
[ 98.474162] Oops: 0000 [#1] SMP
[ 98.474162] Modules linked in:
[ 98.474162] Pid: 3282, comm: trinity-main Tainted: G W 3.9.0-rc1+ #1 Bochs Bochs
[ 98.474162] EIP: 0060:[] EFLAGS: 00000246 CPU: 0
[ 98.474162] EIP is at perf_swevent_init+0x6e/0×130
[ 98.474162] EAX: 00000000 EBX: 00000000 ECX: 88000020 EDX: c6882000
[ 98.474162] ESI: c7b99800 EDI: 88000020 EBP: c6883ec4 ESP: c6883eb4
[ 98.474162] DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[ 98.474162] CR0: 8005003b CR2: e1a89e20 CR3: 068d7000 CR4: 00000690
[ 98.474162] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[ 98.474162] DR6: 00000000 DR7: 00000000
[ 98.474162] Process trinity-main (pid: 3282, ti=c6882000 task=c7884510 task.ti=c6882000)
[ 98.474162] Stack:
[ 98.474162] c7b99800 c19327e0 c7b99800 00000000 c6883edc c10c75a8 c19327e0 00000000
[ 98.474162] c6883f3c c7b998d8 c6883efc c10c78a8 c7884510 c6883f3c c7b99800 c7884510
[ 98.474162] 0000000f 08aa8004 c6883fac c10c808d 00000000 00000000 00000000 00000000
[ 98.474162] Call Trace:
[ 98.474162] [] perf_init_event+0×98/0xc0
[ 98.474162] [] perf_event_alloc+0x2d8/0×440
[ 98.474162] [] sys_perf_event_open+0x32d/0×860
[ 98.474162] [] ? tick_program_event+0×24/0×30
[ 98.474162] [] sysenter_do_call+0×12/0×22
[ 98.474162] Code: 74 13 89 d8 8b 75 f8 8b 5d f4 8b 7d fc 89 ec 5d c3 8d 74 26 00 8b 86 ac 01 00 00 83 f8 ff 74 3d e8 28 fe ff ff 85 c0 89 c3 75 d7 <3e> ff 04 bd a0 9d a8 c1 31 db c7 86 14 02 00 00 80 2c 0c c1 89
[ 98.474162] EIP: [] perf_swevent_init+0x6e/0×130 SS:ESP 0068:c6883eb4
[ 98.474162] CR2: 00000000e1a89e20
[ 98.474162] —[ end trace c303fd4ec49b61f8 ]—
[main] fd[5] = pipe
[main] fd[6] = pipe
[main] fd[7] = pipe
[main] fd[8] = pipe
[main] fd[9] = perf
[main] fd[10] = perf
[main] fd[11] = perf
[main] fd[12] = perf
[main] fd[13] = perf
[main] fd[14] = perf
[ 98.474064] WARNING: unable to handle kernel paging request at e1a89e20
[ 98.474162] IP: [] perf_swevent_init+0x6e/0×130
[ 98.474162] *pde = 00000000
[ 98.474162] Oops: 0000 [#1] SMP
[ 98.474162] Modules linked in:
[ 98.474162] Pid: 3282, comm: trinity-main Tainted: G W 3.9.0-rc1+ #1 Bochs Bochs
[ 98.474162] EIP: 0060:[] EFLAGS: 00000246 CPU: 0
[ 98.474162] EIP is at perf_swevent_init+0x6e/0×130
[ 98.474162] EAX: 00000000 EBX: 00000000 ECX: 88000020 EDX: c6882000
[ 98.474162] ESI: c7b99800 EDI: 88000020 EBP: c6883ec4 ESP: c6883eb4
[ 98.474162] DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[ 98.474162] CR0: 8005003b CR2: e1a89e20 CR3: 068d7000 CR4: 00000690
[ 98.474162] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[ 98.474162] DR6: 00000000 DR7: 00000000
[ 98.474162] Process trinity-main (pid: 3282, ti=c6882000 task=c7884510 task.ti=c6882000)
[ 98.474162] Stack:
[ 98.474162] c7b99800 c19327e0 c7b99800 00000000 c6883edc c10c75a8 c19327e0 00000000
[ 98.474162] c6883f3c c7b998d8 c6883efc c10c78a8 c7884510 c6883f3c c7b99800 c7884510
[ 98.474162] 0000000f 08aa8004 c6883fac c10c808d 00000000 00000000 00000000 00000000
[ 98.474162] Call Trace:
[ 98.474162] [] perf_init_event+0×98/0xc0
[ 98.474162] [] perf_event_alloc+0x2d8/0×440
[ 98.474162] [] sys_perf_event_open+0x32d/0×860
[ 98.474162] [] ? tick_program_event+0×24/0×30
[ 98.474162] [] sysenter_do_call+0×12/0×22
[ 98.474162] Code: 74 13 89 d8 8b 75 f8 8b 5d f4 8b 7d fc 89 ec 5d c3 8d 74 26 00 8b 86 ac 01 00 00 83 f8 ff 74 3d e8 28 fe ff ff 85 c0 89 c3 75 d7 <3e> ff 04 bd a0 9d a8 c1 31 db c7 86 14 02 00 00 80 2c 0c c1 89
[ 98.474162] EIP: [] perf_swevent_init+0x6e/0×130 SS:ESP 0068:c6883eb4
[ 98.474162] CR2: 00000000e1a89e20
[ 98.474162] —[ end trace c303fd4ec49b61f9 ]—

Message from syslogd@debian at Nov 28 23:05:05 …
kernel:[ 98.474162] Process trinity-main (pid: 3282, ti=c6882000 task=c7884510 task.ti=c6882000)

Message from syslogd@debian at Nov 28 23:05:05 …
kernel:[ 98.474162] Stack:

Message from syslogd@debian at Nov 28 23:05:05 …
kernel:[ 98.474162] Call Trace:

Message from syslogd@debian at Nov 28 23:05:05 …
kernel:[ 98.474162] Code: 74 13 89 d8 8b 75 f8 8b 5d f4 8b 7d fc 89 ec 5d c3 8d 74 26 00 8b 86 ac 01 00 00 83 f8 ff 74 3d e8 28 fe ff ff 85 c0 89 c3 75 d7 <3e> ff 04 bd a0 9d a8 c1 31 db c7 86 14 02 00 00 80 2c 0c c1 89

Message from syslogd@debian at Nov 28 23:05:05 …
kernel:[ 98.474162] EIP: [] perf_swevent_init+0x6e/0×130 SS:ESP 0068:c6883eb4
"
result = result.split("\n")
a = parse_trinity(result, "")
puts a