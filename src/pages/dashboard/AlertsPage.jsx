import React from 'react';
import { motion } from 'framer-motion';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { AlertTriangle, Clock, MapPin, Search } from 'lucide-react';

const alerts = [
  { id: 1, title: 'Severe Weather Warning', location: 'Downtown Area', time: '10 mins ago', severity: 'high' },
  { id: 2, title: 'Road Closure', location: 'Highway 101 South', time: '1 hour ago', severity: 'medium' },
  { id: 3, title: 'Public Transit Delay', location: 'Central Station', time: '2 hours ago', severity: 'low' },
  { id: 4, title: 'Flash Flood Watch', location: 'Riverfront District', time: '3 hours ago', severity: 'high' },
];

const severityColors = {
  high: 'bg-red-100 text-red-700 border-red-200 dark:bg-red-900/30 dark:text-red-400 dark:border-red-800',
  medium: 'bg-yellow-100 text-yellow-700 border-yellow-200 dark:bg-yellow-900/30 dark:text-yellow-400 dark:border-yellow-800',
  low: 'bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-800',
};

export function AlertsPage() {
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Safety Alerts</h1>
          <p className="text-slate-600 dark:text-slate-400 text-sm mt-1">Stay informed about your surroundings.</p>
        </div>
        <Button variant="danger" size="lg" className="shadow-lg shadow-red-500/30 sm:w-auto w-full">
          <AlertTriangle className="w-5 h-5 mr-2" />
          SOS Emergency
        </Button>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
        <input 
          type="text" 
          placeholder="Search alerts by location..." 
          className="w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 focus:ring-2 focus:ring-primary-500 outline-none text-slate-900 dark:text-white"
        />
      </div>

      <div className="space-y-4">
        {alerts.map((alert, i) => (
          <motion.div
            key={alert.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: i * 0.1 }}
          >
            <Card className={`border-l-4 p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 ${
              alert.severity === 'high' ? 'border-l-red-500' : 
              alert.severity === 'medium' ? 'border-l-yellow-500' : 'border-l-blue-500'
            }`}>
              <div className="space-y-2">
                <div className="flex items-center space-x-2">
                  <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize border ${severityColors[alert.severity]}`}>
                    {alert.severity} Severity
                  </span>
                  <span className="flex items-center text-xs text-slate-500 dark:text-slate-400">
                    <Clock className="w-3.5 h-3.5 mr-1" />
                    {alert.time}
                  </span>
                </div>
                <h3 className="text-lg font-semibold text-slate-900 dark:text-white">{alert.title}</h3>
                <p className="flex items-center text-sm text-slate-600 dark:text-slate-400">
                  <MapPin className="w-4 h-4 mr-1" />
                  {alert.location}
                </p>
              </div>
              <Button variant="outline" size="sm">View Details</Button>
            </Card>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
