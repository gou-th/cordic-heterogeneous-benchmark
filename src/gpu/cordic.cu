#include <stdio.h>
#include <cuda_runtime.h>

__device__ __constant__ short gamma_val[16]  = {12868, 7596, 4014, 2037, 1023, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1, 0};

__global__ void cordic_kernel(short* angle_in, short* cos_out, short* sin_out, int N) {
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	if (idx < N) {
		short x = 9949;
		short y = 0;
		short z = angle_in[idx];
		for (int i=0; i<16; i++) {
			short x_shift = x>>i;
			short y_shift = y>>i;

		if (z<0) {
			x = x+y_shift;
			y = y-x_shift;
			z = z+gamma_val[i]; }
		else {
			x = x-y_shift;
			y = y+x_shift;
			z = z-gamma_val[i]; }
		}

	cos_out[idx] = x;
	sin_out[idx] = y;
	}
}


void cordic_benchmark(int N, float* out_kernel_ms, float* out_e2e_ms) {
    short *angle_in = NULL, *cos_out = NULL, *sin_out = NULL;
    short *angle_in_gpu = NULL, *cos_out_gpu = NULL, *sin_out_gpu = NULL;

    cudaMallocHost(&angle_in, N*sizeof(short));
    cudaMallocHost(&cos_out, N*sizeof(short));
    cudaMallocHost(&sin_out, N*sizeof(short));
    cudaMalloc(&angle_in_gpu, N*sizeof(short));
    cudaMalloc(&cos_out_gpu, N*sizeof(short));
    cudaMalloc(&sin_out_gpu, N*sizeof(short));
    for(int i=0; i<N; i++) {
        float angle = -1.5708f + (3.1416f * i) / (N-1);
        angle_in[i] = (short)(angle * 16384.0f);
    }

    int threads = 256;
    int blocks = (N+threads-1)/threads;

    cudaMemcpy(angle_in_gpu, angle_in, N*sizeof(short), cudaMemcpyHostToDevice);
    cordic_kernel<<<blocks, threads>>>(angle_in_gpu, cos_out_gpu, sin_out_gpu, N);
    cudaDeviceSynchronize();


    cudaEvent_t k_start, k_stop, e_start, e_stop;
    cudaEventCreate(&k_start); cudaEventCreate(&k_stop);
    cudaEventCreate(&e_start); cudaEventCreate(&e_stop);


    cudaMemcpy(angle_in_gpu, angle_in, N*sizeof(short), cudaMemcpyHostToDevice);
    cudaEventRecord(k_start);
    cordic_kernel<<<blocks, threads>>>(angle_in_gpu, cos_out_gpu, sin_out_gpu, N);
    cudaEventRecord(k_stop);
    cudaEventSynchronize(k_stop);
    cudaEventElapsedTime(out_kernel_ms, k_start, k_stop);


    cudaEventRecord(e_start);
    cudaMemcpy(angle_in_gpu, angle_in, N*sizeof(short), cudaMemcpyHostToDevice);
    cordic_kernel<<<blocks, threads>>>(angle_in_gpu, cos_out_gpu, sin_out_gpu, N);
    cudaMemcpy(cos_out, cos_out_gpu, N*sizeof(short), cudaMemcpyDeviceToHost);
    cudaMemcpy(sin_out, sin_out_gpu, N*sizeof(short), cudaMemcpyDeviceToHost);
    cudaEventRecord(e_stop);
    cudaEventSynchronize(e_stop);
    cudaEventElapsedTime(out_e2e_ms, e_start, e_stop);

    cudaFreeHost(angle_in); cudaFreeHost(cos_out); cudaFreeHost(sin_out);
    cudaFree(angle_in_gpu); cudaFree(cos_out_gpu); cudaFree(sin_out_gpu);
    cudaEventDestroy(k_start); cudaEventDestroy(k_stop);
    cudaEventDestroy(e_start); cudaEventDestroy(e_stop);
}


int main() {
    cudaSetDevice(0);
    int sizes[] = {1000, 10000, 100000, 1000000};
    int n_sizes = 4;
    printf("N,kernel_ms,e2e_ms,throughput_compute_Mps,throughput_system_Mps\n"); fflush(stdout);
    for (int i=0; i<n_sizes; i++) {
        int N = sizes[i];
        float kernel_ms, e2e_ms;
        cordic_benchmark(N, &kernel_ms, &e2e_ms);
        float tp_compute = N / (kernel_ms * 1000.0f);
        float tp_system = N / (e2e_ms * 1000.0f);
        printf("%d,%.4f,%.4f,%.2f,%.2f\n", N, kernel_ms, e2e_ms, tp_compute, tp_system);
    }
    return 0;
}
