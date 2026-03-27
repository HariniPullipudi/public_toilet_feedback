import React from 'react';
import { motion } from 'framer-motion';
import { Card } from '../../components/ui/Card';
import { MapPin, ShieldHalf, CloudRain, Navigation } from 'lucide-react';

export function DashboardOverview() {
  const stats = [
    { title: 'Current Location', value: 'Paris, France', icon: MapPin, color: 'text-blue-500', bg: 'bg-blue-100 dark:bg-blue-500/20' },
    { title: 'Safety Score', value: '85/100', subtitle: 'Safe Zone', icon: ShieldHalf, color: 'text-green-500', bg: 'bg-green-100 dark:bg-green-500/20' },
    { title: 'Weather', value: '72°F', subtitle: 'Light Rain', icon: CloudRain, color: 'text-yellow-500', bg: 'bg-yellow-100 dark:bg-yellow-500/20' },
    { title: 'Trip Status', value: 'Day 3 of 7', subtitle: 'On Schedule', icon: Navigation, color: 'text-purple-500', bg: 'bg-purple-100 dark:bg-purple-500/20' },
  ];

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-slate-900 dark:text-white mb-6">Overview</h1>
      
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6">
        {stats.map((stat, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
          >
            <Card className="p-6">
              <div className="flex items-center space-x-4">
                <div className={`w-12 h-12 rounded-full ${stat.bg} flex items-center justify-center`}>
                  <stat.icon className={`w-6 h-6 ${stat.color}`} />
                </div>
                <div>
                  <h3 className="text-sm font-medium text-slate-500 dark:text-slate-400">{stat.title}</h3>
                  <div className="text-2xl font-bold text-slate-900 dark:text-white">{stat.value}</div>
                  {stat.subtitle && (
                    <div className="text-sm text-slate-500 dark:text-slate-400 mt-1">{stat.subtitle}</div>
                  )}
                </div>
              </div>
            </Card>
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
        <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.4 }}>
          <Card className="p-6 h-[400px] flex flex-col">
            <h2 className="text-lg font-bold text-slate-900 dark:text-white mb-4">Nearby Alerts</h2>
            <div className="flex-1 flex items-center justify-center border-2 border-dashed border-slate-200 dark:border-slate-800 rounded-xl bg-slate-50 dark:bg-slate-900/50">
               <p className="text-slate-500 dark:text-slate-400">All clear in your area!</p>
            </div>
          </Card>
        </motion.div>
        
        <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.5 }}>
          <Card className="p-6 h-[400px] flex flex-col">
            <h2 className="text-lg font-bold text-slate-900 dark:text-white mb-4">Upcoming Schedule</h2>
            <div className="flex-1 overflow-y-auto space-y-4 pr-2">
              {[1, 2, 3].map((_, i) => (
                <div key={i} className="flex items-start space-x-4 p-3 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                  <div className="w-10 h-10 rounded-full bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center shrink-0">
                    <Navigation className="w-5 h-5 text-primary-600 dark:text-primary-500" />
                  </div>
                  <div>
                     <h4 className="text-sm font-medium text-slate-900 dark:text-white">Visit Louvre Museum</h4>
                     <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">Today • 2:00 PM</p>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}
