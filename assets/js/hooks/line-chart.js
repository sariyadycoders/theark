import LineChart from "../line-chart";

const LineChartHook = {
    mounted() {
        const {labels, values, heading} = JSON.parse(this.el.dataset.chartData)
        this.chart = new LineChart(this.el, labels, values, heading)
    }
}

export default LineChartHook