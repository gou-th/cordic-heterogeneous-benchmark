import csv
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

N_vals, kernel_ms, e2e_ms, tp_compute, tp_system = [], [], [], [], []

with open("results.csv", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    reader.fieldnames = [name.strip() for name in reader.fieldnames if name]
    for row in reader:
        N_vals.append(int(row["N"]))
        kernel_ms.append(float(row["kernel_ms"]))
        e2e_ms.append(float(row["e2e_ms"]))
        tp_compute.append(float(row["throughput_compute_Mps"]))
        tp_system.append(float(row["throughput_system_Mps"]))

fpga_tp = [100.0] * len(N_vals)
fpga_lat_ms = [n / 1e8 * 1e3 for n in N_vals]

plt.style.use('dark_background')
plt.rcParams.update({
    "figure.facecolor": "#0d1117",
    "axes.facecolor": "#0d1117",
    "grid.color": "#21262d",
    "font.family": "monospace",
})

GPU_COMPUTE = "#58a6ff"
GPU_SYSTEM = "#3fb950"
FPGA_COLOR = "#f78166"

# Throughput
fig, ax = plt.subplots(figsize=(9, 5.5))
ax.plot(N_vals, tp_compute, "o-", color=GPU_COMPUTE, lw=2, label="GPU Compute", alpha=0.9)
ax.plot(N_vals, tp_system, "s-", color=GPU_SYSTEM, lw=2, label="GPU System", alpha=0.9)
ax.plot(N_vals, fpga_tp, "^-", color=FPGA_COLOR, lw=2, label="FPGA @ 100MHz", alpha=0.9)
ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlabel("N (angles)")
ax.set_ylabel("Throughput (M/s)")
ax.set_title("CORDIC Throughput: RTX 4060 vs Artix-7")
ax.legend(framealpha=0.2)
ax.grid(True, which="both")
ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f"{int(x):,}"))
fig.tight_layout()
fig.savefig("throughput_vs_N.png", dpi=150, facecolor="#0d1117")
plt.close()

# Latency
fig, ax = plt.subplots(figsize=(9, 5.5))
ax.plot(N_vals, kernel_ms, "o-", color=GPU_COMPUTE, lw=2, label="GPU Kernel", alpha=0.9)
ax.plot(N_vals, e2e_ms, "s-", color=GPU_SYSTEM, lw=2, label="GPU E2E", alpha=0.9)
ax.plot(N_vals, fpga_lat_ms, "^-", color=FPGA_COLOR, lw=2, label="FPGA", alpha=0.9)
ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlabel("N (angles)")
ax.set_ylabel("Latency (ms)")
ax.set_title("CORDIC Latency: RTX 4060 vs Artix-7")
ax.legend(framealpha=0.2)
ax.grid(True, which="both")
ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f"{int(x):,}"))
fig.tight_layout()
fig.savefig("latency_vs_N.png", dpi=150, facecolor="#0d1117")
plt.close()

# Compute vs System
x = np.arange(len(N_vals))
width = 0.35
labels = [f"{n:,}" for n in N_vals]

fig, ax = plt.subplots(figsize=(9, 5.5))
bars1 = ax.bar(x - width/2, tp_compute, width, label="Compute", color=GPU_COMPUTE, alpha=0.9)
bars2 = ax.bar(x + width/2, tp_system, width, label="System", color=GPU_SYSTEM, alpha=0.9)
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.set_xlabel("N (angles)")
ax.set_ylabel("Throughput (M/s)")
ax.set_title("PCIe Overhead — RTX 4060")
ax.legend(framealpha=0.2)
ax.grid(True, axis="y")
fig.tight_layout()
fig.savefig("compute_vs_system.png", dpi=150, facecolor="#0d1117")
plt.close()
