import React from 'react';
import { motion } from 'framer-motion';
import { Card } from '../../components/ui/Card';
import { MapPin } from 'lucide-react';

const markers = [
  { id: 1, x: '20%', y: '30%', status: 'safe', label: 'Downtown Area (Safe)' },
  { id: 2, x: '50%', y: '60%', status: 'safe', label: 'Park District (Safe)' },
  { id: 3, x: '70%', y: '20%', status: 'danger', label: 'North End (Caution)' },
  { id: 4, x: '80%', y: '80%', status: 'danger', label: 'Industrial Zone (Avoid)' },
];

export function MapPage() {
  return (
    <div className="h-full flex flex-col space-y-4">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Interactive Map</h1>
        <p className="text-slate-600 dark:text-slate-400 text-sm mt-1">Real-time safety zones and alerts overview.</p>
      </div>

      <Card className="flex-1 relative overflow-hidden bg-slate-100 dark:bg-slate-900 p-0 min-h-[500px]">
        {/* Mock Map Background */}
        <div className="absolute inset-0 opacity-20 dark:opacity-10" style={{
          backgroundImage: 'radial-gradient(circle at 2px 2px, #94a3b8 1px, transparent 0)',
          backgroundSize: '40px 40px'
        }} />
        
        {/* Map UI Overlay */}
        <div className="absolute inset-0">
          {markers.map((marker) => (
            <motion.div
              key={marker.id}
              className="absolute group"
              style={{ left: marker.x, top: marker.y }}
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: 'spring', bounce: 0.5 }}
            >
              {/* Tooltip */}
              <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 w-max px-3 py-1.5 bg-slate-900 dark:bg-slate-800 text-white text-xs font-medium rounded shadow-lg opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-10">
                {marker.label}
              </div>
              
              {/* Marker Icon */}
              <div className={`w-8 h-8 -translate-x-1/2 -translate-y-1/2 rounded-full flex items-center justify-center cursor-pointer shadow-lg ${
                marker.status === 'safe' 
                  ? 'bg-green-500 text-white' 
                  : 'bg-red-500 text-white'
              }`}>
                <MapPin className="w-5 h-5" />
                
                {marker.status === 'danger' && (
                  <span className="absolute w-full h-full rounded-full bg-red-500 animate-ping opacity-75"></span>
                )}
              </div>
            </motion.div>
          ))}
        </div>

        {/* Legend */}
        <div className="absolute bottom-6 left-6 bg-white/90 dark:bg-slate-900/90 backdrop-blur p-4 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
          <h4 className="text-sm font-semibold mb-3 text-slate-900 dark:text-white">Legend</h4>
          <div className="space-y-2">
            <div className="flex items-center space-x-2 text-sm text-slate-600 dark:text-slate-400">
              <div className="w-3 h-3 rounded-full bg-green-500"></div>
              <span>Safe Zone</span>
            </div>
            <div className="flex items-center space-x-2 text-sm text-slate-600 dark:text-slate-400">
              <div className="w-3 h-3 rounded-full bg-red-500"></div>
              <span>Danger Zone</span>
            </div>
          </div>
        </div>
      </Card>
    </div>
  );
}
