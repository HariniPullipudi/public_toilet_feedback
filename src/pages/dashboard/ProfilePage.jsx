import React from 'react';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Mail, Phone, Settings, Shield, Clock, Camera } from 'lucide-react';

export function ProfilePage() {
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Profile settings</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-1 space-y-6">
          <Card className="p-6 text-center">
            <div className="relative inline-block mb-4">
              <div className="w-24 h-24 rounded-full bg-slate-200 dark:bg-slate-800 border-4 border-white dark:border-slate-950 overflow-hidden mx-auto shadow-sm">
                {/* Placeholder Avatar */}
                <div className="w-full h-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white text-3xl font-bold">
                  JD
                </div>
              </div>
              <button className="absolute bottom-0 right-0 p-1.5 bg-white dark:bg-slate-800 rounded-full border border-slate-200 dark:border-slate-700 shadow-sm text-slate-600 dark:text-slate-300 hover:text-primary-600 transition-colors">
                <Camera className="w-4 h-4" />
              </button>
            </div>
            
            <h2 className="text-xl font-bold text-slate-900 dark:text-white">John Doe</h2>
            <p className="text-slate-500 dark:text-slate-400 text-sm mb-4">Frequent Traveler</p>
            <Button variant="outline" className="w-full">Edit Profile</Button>
          </Card>

          <Card className="p-0 overflow-hidden">
            <div className="divide-y divide-slate-100 dark:divide-slate-800">
              <button className="w-full flex items-center px-4 py-3 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-900/50 transition-colors">
                <Settings className="w-4 h-4 mr-3 text-slate-400" /> Account Settings
              </button>
              <button className="w-full flex items-center px-4 py-3 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-900/50 transition-colors">
                <Shield className="w-4 h-4 mr-3 text-slate-400" /> Privacy & Security
              </button>
              <button className="w-full flex items-center px-4 py-3 text-sm text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors">
                Sign Out
              </button>
            </div>
          </Card>
        </div>

        <div className="md:col-span-2 space-y-6">
          <Card className="p-6">
            <h3 className="text-lg font-semibold text-slate-900 dark:text-white mb-4">Personal Information</h3>
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">First Name</label>
                  <p className="text-sm font-medium text-slate-900 dark:text-white bg-slate-50 dark:bg-slate-900 px-3 py-2 rounded-lg border border-slate-100 dark:border-slate-800">John</p>
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">Last Name</label>
                  <p className="text-sm font-medium text-slate-900 dark:text-white bg-slate-50 dark:bg-slate-900 px-3 py-2 rounded-lg border border-slate-100 dark:border-slate-800">Doe</p>
                </div>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">Email Address</label>
                <div className="flex items-center text-sm font-medium text-slate-900 dark:text-white bg-slate-50 dark:bg-slate-900 px-3 py-2 rounded-lg border border-slate-100 dark:border-slate-800">
                  <Mail className="w-4 h-4 mr-2 text-slate-400" />
                  johndoe@example.com
                </div>
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">Phone Number</label>
                <div className="flex items-center text-sm font-medium text-slate-900 dark:text-white bg-slate-50 dark:bg-slate-900 px-3 py-2 rounded-lg border border-slate-100 dark:border-slate-800">
                  <Phone className="w-4 h-4 mr-2 text-slate-400" />
                  +1 (555) 123-4567
                </div>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <h3 className="text-lg font-semibold text-slate-900 dark:text-white mb-4 flex items-center">
              <Clock className="w-5 h-5 mr-2 text-primary-500" />
              Past Trips History
            </h3>
            
            <div className="space-y-4">
              {[
                { dest: 'Tokyo, Japan', date: 'Oct 12 - 20, 2023', code: 'Completed' },
                { dest: 'Rome, Italy', date: 'Jul 4 - 14, 2023', code: 'Completed' },
              ].map((trip, i) => (
                <div key={i} className="flex items-center justify-between p-4 rounded-xl border border-slate-100 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-900 transition-colors">
                  <div>
                    <h4 className="font-semibold text-slate-900 dark:text-white">{trip.dest}</h4>
                    <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">{trip.date}</p>
                  </div>
                  <span className="px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400">
                    {trip.code}
                  </span>
                </div>
              ))}
            </div>
            <Button variant="ghost" className="w-full mt-4 text-sm">View All History</Button>
          </Card>
        </div>
      </div>
    </div>
  );
}
