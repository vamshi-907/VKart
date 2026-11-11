import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
 final String title;
 final String value;
 final IconData icon;
 final Color? iconColor;
 final String? subtitle;
 final double? trend;

 const StatCard({
 super.key,
 required this.title,
 required this.value,
 required this.icon,
 this.iconColor,
 this.subtitle,
 this.trend,
 });

 @override Widget build(BuildContext context) {
 return Card(
 elevation: 2,
 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
 child: Padding(
 padding: const EdgeInsets.all(16),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Container(
 padding: const EdgeInsets.all(8),
 decoration: BoxDecoration(
 color: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
 borderRadius: BorderRadius.circular(8),
 ),
 child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 20),
 ),
 const Spacer(),
 if (trend != null)
 Text(
 '${trend! > 0 ? '+' : ''}${trend!.toStringAsFixed(1)}%',
 style: TextStyle(
 color: trend! > 0 ? Colors.green : Colors.red,
 fontWeight: FontWeight.w600,
 fontSize: 12,
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 Text(
 title,
 style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
 ),
 const SizedBox(height: 4),
 Text(
 value,
 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
 ),
 if (subtitle != null) ...[
 const SizedBox(height: 4),
 Text(
 subtitle!,
 style: TextStyle(color: Colors.grey[500], fontSize: 11),
 ),
 ],
 ],
 ),
 ),
 );
 }
}
