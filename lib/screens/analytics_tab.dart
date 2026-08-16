import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // --- DATA PROCESSING ---
        // We only want to analyze ACTIVE incidents for these charts
        final activeTasks = taskProvider.tasks.where((t) => t.status != 'Resolved').toList();

        if (activeTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No active data to analyze', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        // 1. Severity Breakdown Counters
        int critical = 0, high = 0, medium = 0, low = 0;

        // 2. Team Workload Counters
        Map<String, int> teamCounts = {
          'Alpha Team': 0, 'Bravo Team': 0, 'Cyber Sec': 0, 'Net Ops': 0, 'Unassigned': 0
        };

        for (var task in activeTasks) {
          // Count Severities
          switch (task.severity.toLowerCase()) {
            case 'critical': critical++; break;
            case 'high': high++; break;
            case 'medium': medium++; break;
            default: low++; break;
          }
          // Count Team Assignments
          if (teamCounts.containsKey(task.assignee)) {
            teamCounts[task.assignee] = teamCounts[task.assignee]! + 1;
          } else {
            teamCounts['Unassigned'] = teamCounts['Unassigned']! + 1;
          }
        }

        // Find the highest workload to scale the Bar Chart Y-Axis
        double maxWorkload = teamCounts.values.reduce((a, b) => a > b ? a : b).toDouble();
        if (maxWorkload == 0) maxWorkload = 5; // Default scale if empty

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Active Incident Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // --- DONUT CHART: SEVERITY BREAKDOWN ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('Severity Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            sections: [
                              if (critical > 0) PieChartSectionData(color: Colors.red.shade700, value: critical.toDouble(), title: '$critical', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              if (high > 0) PieChartSectionData(color: Colors.orange.shade800, value: high.toDouble(), title: '$high', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              if (medium > 0) PieChartSectionData(color: Colors.amber.shade700, value: medium.toDouble(), title: '$medium', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              if (low > 0) PieChartSectionData(color: Colors.blue.shade600, value: low.toDouble(), title: '$low', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendIndicator(Colors.red.shade700, 'Critical'),
                          const SizedBox(width: 12),
                          _buildLegendIndicator(Colors.orange.shade800, 'High'),
                          const SizedBox(width: 12),
                          _buildLegendIndicator(Colors.amber.shade700, 'Medium'),
                          const SizedBox(width: 12),
                          _buildLegendIndicator(Colors.blue.shade600, 'Low'),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- BAR CHART: TEAM WORKLOAD ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Live Team Workload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxWorkload + 2, // Give it some breathing room at the top
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold);
                                    String text;
                                    switch (value.toInt()) {
                                      case 0: text = 'Alpha'; break;
                                      case 1: text = 'Bravo'; break;
                                      case 2: text = 'Cyber'; break;
                                      case 3: text = 'NetOps'; break;
                                      case 4: text = 'Unassigned'; break;
                                      default: text = ''; break;
                                    }
                                    return SideTitleWidget(meta: meta, child: Text(text, style: style));
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      if (value % 1 != 0) return const SizedBox.shrink(); // Only show whole numbers
                                      return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                                    }
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _buildBarGroup(0, teamCounts['Alpha Team']!, Colors.blue),
                              _buildBarGroup(1, teamCounts['Bravo Team']!, Colors.orange),
                              _buildBarGroup(2, teamCounts['Cyber Sec']!, Colors.red),
                              _buildBarGroup(3, teamCounts['Net Ops']!, Colors.green),
                              _buildBarGroup(4, teamCounts['Unassigned']!, Colors.blueGrey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendIndicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}