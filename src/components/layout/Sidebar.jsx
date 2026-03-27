import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, MapPinned, Bell, Calendar, User } from 'lucide-react';
import { cn } from '../../lib/utils';

const navItems = [
  { icon: LayoutDashboard, label: 'Dashboard', path: '/dashboard', end: true },
  { icon: MapPinned, label: 'Map', path: '/dashboard/map' },
  { icon: Bell, label: 'Alerts', path: '/dashboard/alerts' },
  { icon: Calendar, label: 'Trip Planner', path: '/dashboard/planner' },
  { icon: User, label: 'Profile', path: '/dashboard/profile' },
];

export function Sidebar() {
  return (
    <aside className="w-64 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950/50 h-[calc(100vh-4rem)] sticky top-16 hidden lg:flex flex-col overflow-y-auto">
      <div className="p-4 flex-1">
        <ul className="space-y-1">
          {navItems.map((item) => (
            <li key={item.path}>
              <NavLink
                to={item.path}
                end={item.end}
                className={({ isActive }) =>
                  cn(
                    'flex items-center space-x-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors',
                    isActive
                      ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400'
                      : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-900/50 hover:text-slate-900 dark:hover:text-slate-100'
                  )
                }
              >
                <item.icon className="w-5 h-5" />
                <span>{item.label}</span>
              </NavLink>
            </li>
          ))}
        </ul>
      </div>
    </aside>
  );
}
