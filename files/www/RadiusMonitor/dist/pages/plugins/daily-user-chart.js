// Ganti dengan URL API PHP kamu
const apiUrl = './api/daily_user.php';

// Ambil data dari API PHP
fetch(apiUrl)
  .then(response => response.json())
  .then(data => {
    console.log(data); // Periksa data di konsol

    // Ambil konteks grafik
    var ctx = document.getElementById('chart-bars').getContext('2d');

    // Fungsi untuk mendapatkan gradien
    function getGradient(ctx, chartArea) {
      var gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
      gradient.addColorStop(0, 'rgba(54, 162, 235, 1)');
      gradient.addColorStop(1, 'rgba(54, 162, 235, 0)');
      return gradient;
    }

    // Inisialisasi grafik dengan data dari API
    var myCustomersChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: data.labels, // Label sumbu X dari data API
        datasets: [{
          data: data.data, // Data grafik dari data API
          tension: 0.4,
          backgroundColor: function(context) {
            var chart = context.chart;
            var ctx = chart.ctx;
            var chartArea = chart.chartArea;
            if (!chartArea) {
              return null;
            }
            return getGradient(ctx, chartArea);
          },
          borderColor: 'rgba(54, 162, 235, 1)',
          borderWidth: 2,
          fill: true
        }]
      },
      options: {
        scales: {
          y: {
            display: true
          },
          x: {
            display: true
          }
        },
        elements: {
          point: {
            radius: 1
          }
        },
        plugins: {
          legend: {
            display: false,
          },
          title: {
            display: false,
            text: ['Daily Login'],
            align: 'center',
            color: '#fff',
            font: {
              size: 16,
              family: 'Inter',
              weight: '600',
              lineHeight: 1.4
            },
            padding: {
              top: 20
            }
          }
        },
        maintainAspectRatio: false
      }
    });
  })
  .catch(error => {
    console.error('Error fetching chart data:', error);
  });
  