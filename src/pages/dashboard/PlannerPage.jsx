import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Plane, Calendar as CalendarIcon, MapPin, Plus, Trash2, Navigation } from 'lucide-react';

export function PlannerPage() {
  const [destinations, setDestinations] = useState([
    { id: 1, city: 'London, UK', days: 3 },
  ]);

  const addDestination = () => {
    setDestinations([...destinations, { id: Date.now(), city: '', days: 1 }]);
  };

  const removeDestination = (id) => {
    if (destinations.length > 1) {
      setDestinations(destinations.filter(d => d.id !== id));
    }
  };

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Trip Planner</h1>
        <p className="text-slate-600 dark:text-slate-400 text-sm mt-1">Plan your next safe adventure with ease.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Planner Form */}
        <div className="lg:col-span-1 space-y-6">
          <Card className="p-6">
            <h2 className="text-lg font-semibold text-slate-900 dark:text-white mb-4">Trip Details</h2>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">Start Date</label>
                <div className="relative">
                  <CalendarIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                  <input type="date" className="w-full pl-9 pr-3 py-2 border border-slate-300 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-950 text-slate-900 dark:text-white text-sm" />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">Destinations</label>
                <AnimatePresence>
                  {destinations.map((dest, i) => (
                    <motion.div
                      key={dest.id}
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className="flex gap-2 mb-3"
                    >
                      <div className="relative flex-1">
                        <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                        <input 
                          type="text" 
                          placeholder="City" 
                          defaultValue={dest.city}
                          className="w-full pl-9 pr-3 py-2 border border-slate-300 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-950 text-slate-900 dark:text-white text-sm" 
                        />
                      </div>
                      <input 
                        type="number" 
                        min="1" 
                        placeholder="Days" 
                        defaultValue={dest.days}
                        className="w-20 px-3 py-2 border border-slate-300 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-950 text-slate-900 dark:text-white text-sm text-center" 
                      />
                      <button 
                        onClick={() => removeDestination(dest.id)}
                        className={`p-2 rounded-lg border border-slate-300 dark:border-slate-700 hover:bg-red-50 dark:hover:bg-red-900/20 text-slate-400 hover:text-red-500 transition-colors ${destinations.length === 1 && 'opacity-50 cursor-not-allowed'}`}
                        disabled={destinations.length === 1}
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </motion.div>
                  ))}
                </AnimatePresence>
                
                <Button variant="ghost" size="sm" onClick={addDestination} className="w-full mt-2 border border-dashed border-slate-300 dark:border-slate-700">
                  <Plus className="w-4 h-4 mr-2" /> Add Destination
                </Button>
              </div>

              <Button className="w-full mt-4">Generate Itinerary</Button>
            </div>
          </Card>
        </div>

        {/* Suggested Itinerary */}
        <div className="lg:col-span-2">
          <Card className="p-0 h-full min-h-[500px] flex flex-col bg-slate-50/50 dark:bg-slate-900/30">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800">
              <h2 className="text-lg font-semibold text-slate-900 dark:text-white flex items-center">
                <Plane className="w-5 h-5 mr-2 text-primary-500" />
                Suggested Itinerary
              </h2>
            </div>
            
            <div className="p-6 space-y-6 flex-1 overflow-y-auto">
              {[1, 2, 3].map((day) => (
                <div key={day} className="relative pl-6 border-l-2 border-primary-200 dark:border-primary-900/50">
                  <div className="absolute w-4 h-4 bg-primary-500 rounded-full -left-[9px] top-1 border-4 border-white dark:border-slate-950"></div>
                  <h3 className="font-semibold text-slate-900 dark:text-white mb-3">Day {day} • Local Exploration</h3>
                  
                  <div className="space-y-3">
                    {['Morning', 'Afternoon'].map((time) => (
                      <Card key={time} className="p-4 bg-white dark:bg-slate-900">
                        <div className="flex justify-between items-start">
                          <div>
                            <span className="text-xs font-semibold text-primary-600 dark:text-primary-400 uppercase tracking-wider">{time}</span>
                            <h4 className="font-medium text-slate-900 dark:text-white mt-1">Visit Historical Center</h4>
                            <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">Safe zone, guided tours recommended.</p>
                          </div>
                          <Navigation className="w-4 h-4 text-slate-400 mt-1" />
                        </div>
                      </Card>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
