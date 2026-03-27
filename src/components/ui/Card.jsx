import React from 'react';
import { cn } from '../../lib/utils';
import { motion } from 'framer-motion';

export function Card({ className, children, hover = false, ...props }) {
  return (
    <motion.div
      whileHover={hover ? { y: -5, transition: { duration: 0.2 } } : {}}
      className={cn(
        'bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden',
        className
      )}
      {...props}
    >
      {children}
    </motion.div>
  );
}
