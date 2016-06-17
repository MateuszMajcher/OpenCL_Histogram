__kernel void vecAdd(__global int* a, volatile __global int* c,
    __constant uint* rows,
    __constant uint* cols)
{
    unsigned int x = get_global_id(0);
    unsigned int y = get_global_id(1);

    int loc_x = get_local_id(0);
    int loc_y = get_local_id(1);
    int size_x = get_local_size(0);
    int size_y = get_local_size(1);
    volatile __local int localHistogram[256];

 

  

    if ((x < *cols) && (y < *rows)) {
		
		int localid = loc_y * size_x + loc_x;
        if (localid < 256) {
            localHistogram[localid] = 0;
        }
         barrier(CLK_LOCAL_MEM_FENCE);
  
  
        unsigned int i = y * (*cols) + x;
		 atomic_inc(&localHistogram[a[i]]);  

        barrier(CLK_LOCAL_MEM_FENCE);

        if ((get_local_id(0) <= 16) && (get_local_id(1) <= 16)) {

            atomic_add(&c[localid], localHistogram[localid]);
        }
        mem_fence(CLK_GLOBAL_MEM_FENCE);
    }
}