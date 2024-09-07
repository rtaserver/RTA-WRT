let chart;

function convertToGB(value, unit) {
    switch (unit) {
        case 'GB':
            return value;
        case 'MB':
            return value / 1024;
        case 'KB':
            return value / (1024 * 1024);
        case 'B':
            return value / (1024 * 1024 * 1024);
        default:
            return 0;
    }
}

function processQuotaData(quotaData) {
    return quotaData.map(item => ({
        tanggal: item.tanggal,
        total_kuota_gb: convertToGB(item.total_kuota, item.unit),
        total_kuota_asli: item.total_kuota,
        unit: item.unit
    }));
}

function updateChart(type) {
    fetch('./api/data.php')
        .then(response => response.json())
        .then(data => {
            const dailyLabels = data.daily_revenue.map(item => item.tanggal);
            const dailyValues = data.daily_revenue.map(item => item.total_pendapatan);

            const processedDailyQuota = processQuotaData(data.daily_quota);
            const dailyQuotaLabels = processedDailyQuota.map(item => item.tanggal);
            const dailyQuotaValues = processedDailyQuota.map(item => item.total_kuota_gb);
            const dailyQuotaOriginals = processedDailyQuota.map(item => item.total_kuota_asli);
            const dailyQuotaUnits = processedDailyQuota.map(item => item.unit);

            const monthlyLabels = data.monthly_revenue.map(item => item.bulan);
            const monthlyValues = data.monthly_revenue.map(item => item.total_pendapatan);

            const processedMonthlyQuota = processQuotaData(data.monthly_quota);
            const monthlyQuotaLabels = processedMonthlyQuota.map(item => item.bulan);
            const monthlyQuotaValues = processedMonthlyQuota.map(item => item.total_kuota_gb);
            const monthlyQuotaOriginals = processedMonthlyQuota.map(item => item.total_kuota_asli);
            const monthlyQuotaUnits = processedMonthlyQuota.map(item => item.unit);

            const yearlyLabels = data.yearly_revenue.map(item => item.tahun);
            const yearlyValues = data.yearly_revenue.map(item => item.total_pendapatan);

            const processedYearlyQuota = processQuotaData(data.yearly_quota);
            const yearlyQuotaLabels = processedYearlyQuota.map(item => item.tahun);
            const yearlyQuotaValues = processedYearlyQuota.map(item => item.total_kuota_gb);
            const yearlyQuotaOriginals = processedYearlyQuota.map(item => item.total_kuota_asli);
            const yearlyQuotaUnits = processedYearlyQuota.map(item => item.unit);

            const ctx = document.getElementById('combinedChart').getContext('2d');

            if (chart) {
                chart.destroy();
            }

            let labels = [];
            let datasets = [];
            let quotaOriginals = [];
            let quotaUnits = [];

            switch (type) {
                case 'daily':
                    labels = dailyLabels;
                    datasets = [
                        {
                            label: 'Pendapatan',
                            data: dailyValues,
                            backgroundColor: 'rgba(54, 162, 235, 50)',
                            borderColor: 'rgba(54, 162, 235, 50)',
                            borderWidth: 1,
                            yAxisID: 'y1',
                            type: 'line',
                            cubicInterpolationMode: 'monotone',
                            tension: 0.4
                        },
                        {
                            label: 'Kuota',
                            data: dailyQuotaValues,
                            backgroundColor: 'rgba(255, 206, 86, 50)',
                            borderColor: 'rgba(255, 206, 86, 50)',
                            borderWidth: 1,
                            yAxisID: 'y2',
                            type: 'bar'
                        }
                    ];
                    quotaOriginals = dailyQuotaOriginals;
                    quotaUnits = dailyQuotaUnits;
                    break;
                case 'monthly':
                    labels = monthlyLabels;
                    datasets = [
                        {
                            label: 'Pendapatan',
                            data: monthlyValues,
                            backgroundColor: 'rgba(75, 192, 192, 50)',
                            borderColor: 'rgba(75, 192, 192, 50)',
                            borderWidth: 1,
                            type: 'line',
                            cubicInterpolationMode: 'monotone',
                            tension: 0.4
                        },
                        {
                            label: 'Kuota',
                            data: monthlyQuotaValues,
                            backgroundColor: 'rgba(153, 102, 255, 50)',
                            borderColor: 'rgba(153, 102, 255, 50)',
                            borderWidth: 1,
                            yAxisID: 'y2',
                            type: 'bar'
                        }
                    ];
                    quotaOriginals = monthlyQuotaOriginals;
                    quotaUnits = monthlyQuotaUnits;
                    break;
                case 'yearly':
                    labels = yearlyLabels;
                    datasets = [
                        {
                            label: 'Pendapatan',
                            data: yearlyValues,
                            backgroundColor: 'rgba(255, 99, 132, 50)',
                            borderColor: 'rgba(255, 99, 132, 50)',
                            borderWidth: 1,
                            type: 'line',
                            cubicInterpolationMode: 'monotone',
                            tension: 0.4
                        },
                        {
                            label: 'Kuota',
                            data: yearlyQuotaValues,
                            backgroundColor: 'rgba(255, 159, 64, 50)',
                            borderColor: 'rgba(255, 159, 64, 50)',
                            borderWidth: 1,
                            yAxisID: 'y2',
                            type: 'bar'
                        }
                    ];
                    quotaOriginals = yearlyQuotaOriginals;
                    quotaUnits = yearlyQuotaUnits;
                    break;
            }

            chart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: datasets
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'top',
                            align: 'center',
                            labels: {
                                boxWidth: 8,
                                boxHeight: 8,
                                usePointStyle: true,
                                font: {
                                    size: 12,
                                    weight: '500'
                                }
                            }
                        },
                        tooltip: {
                            enabled: true,
                            callbacks: {
                                label: function(tooltipItem) {
                                    if (tooltipItem.datasetIndex === 1) {
                                        const originalValue = quotaOriginals[tooltipItem.dataIndex];
                                        const unit = quotaUnits[tooltipItem.dataIndex];
                                        return `${originalValue} ${unit}`;
                                    }
                                    return tooltipItem.raw;
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            type: 'category',
                            labels: labels
                        },
                        y1: {
                            type: 'linear',
                            position: 'left',
                            title: {
                                display: false,
                                text: 'Pendapatan'
                            },
                            beginAtZero: true
                        },
                        y2: {
                            type: 'linear',
                            position: 'right',
                            title: {
                                display: false,
                                text: 'Kuota'
                            },
                            beginAtZero: true,
                            grid: {
                                drawOnChartArea: false
                            }
                        }
                    }
                }
            });
        })
        .catch(error => console.error('Error fetching data:', error));
}

updateChart('daily');

document.getElementById('dataSelect').addEventListener('change', function() {
    const selectedValue = this.value;
    updateChart(selectedValue);
});

setInterval(() => {
    const currentValue = document.getElementById('dataSelect').value;
    updateChart(currentValue);
}, 60000); // 1000 ms = 1 detik
