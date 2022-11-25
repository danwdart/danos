; malloc
; Standard heap pointer = HEAP_PTR_SEGMENT:HEAP_PTR_OFFSET
; Standard heap start = HEAP_START_SEGMENT:HEAP_START_OFFSET

init_heap:
    ; Copy the start location into the heap pointer.
    ret

malloc:
    ; Grab the number of bytes required from the stack header
    ; Get the heap head
    ; Set di to the current heap head
    ; Pull that number of bytes from si and copy it over (via di)
    ; Update the heap header
    ; Push the original heap header.
    ret

free:
    ; Decrement the heap header by the number of bytes indicated in the location of the stack header.
    ret