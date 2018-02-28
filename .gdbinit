#set solib-search-path /usr/lib64/debug/
#set solib-search-path /mnt/hd/IoT/env/firmadyne/images/lib/
#set solib-search-path /mnt/hd/IoT/study/cve-2013-0230/_AirTies_RT-212TT_FW_1.2.0.23_FullImage.bin.extracted/squashfs-root/lib/

#source /mnt/hd/binary/tools/peda/peda.py

#set architecture mips
#target remote 192.168.86.103:1234
#target remote :1234

#source /home/lifeand/.gdbinit-gef.py
#source /home/lifeand/.local/lib64/python2.7/site-packages/voltron/entry.py

# pwngdb
source /mnt/hd/binary/tools/pwndbg/gdbinit.py
source /mnt/hd/binary/tools/Pwngdb/pwngdb.py 
source /mnt/hd/binary/tools/Pwngdb/angelheap/gdbinit.py 

define hook-run
python
import angelheap
angelheap.init_angelheap()
end
end



define my_malloc_stats
  set $in_use = mp_.mmapped_mem
  set $system = mp_.mmapped_mem
  set $arena = &main_arena

  set $arena_n = 0

  # mALLINFo
  while $arena
    set $system = $system + $arena->system_mem

    set $avail = (($arena->top)->size & ~(0x1 | 0x2 | 0x4))

    set $fastavail = 0
    set $i = 0

    # traverse fastbins
    while $i < 10
      set $p = (($arena)->fastbinsY[$i])
      while $p
        set $fastavail = $fastavail + (($p)->size & ~(0x1 | 0x2 | 0x4))
        set $p = $p->fd
      end
      set $i = $i + 1
    end

    set $avail = $avail + $fastavail

    # traverse regular bins
    set $i = 1
    while $i < 128
      set $b = (mbinptr) (((char *) &(($arena)->bins[(($i) - 1) * 2])) - 16)
      set $p = $b->bk
      while $p != $b
        set $avail = $avail + (($p)->size & ~(0x1 | 0x2 | 0x4))
        set $p = $p->bk
      end
      set $i = $i + 1
    end

    printf "Arena: %u\nsystem bytes     = %10lu\nin use bytes     = %10lu\n", $arena_n, $arena->system_mem, ($arena->system_mem - $avail)

    set $in_use = $in_use + ($arena->system_mem - $avail)

    set $arena = $arena->next
    if $arena == &main_arena
      loop_break
    end
    set $arena_n = $arena_n + 1
  end

  printf "Total:\nsystem bytes     = %10lu\nin use bytes     = %10lu\n", $system, $in_use
end


