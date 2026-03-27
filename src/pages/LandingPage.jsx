import React from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { Button } from '../components/ui/Button';
import { ShieldCheck, MapPin, BellRing, Sparkles } from 'lucide-react';

const features = [
  { icon: ShieldCheck, title: 'Real-time Safety Scores', desc: 'Get live updates on the safety of your destination areas.' },
  { icon: MapPin, title: 'Safe Zone Mapping', desc: 'Interactive maps highlighting safe zones and areas to avoid.' },
  { icon: BellRing, title: 'Instant Alerts', desc: 'Receive immediate notifications about nearby incidents.' },
  { icon: Sparkles, title: 'Smart Trip Planner', desc: 'AI-assisted itinerary generation based on safety data.' },
];

export function LandingPage() {
  return (
    <div className="flex flex-col min-h-[calc(100vh-4rem)]">
      {/* Hero Section */}
      <section className="relative flex-1 flex items-center justify-center overflow-hidden bg-slate-900 text-white">
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#4f4f4f2e_1px,transparent_1px),linear-gradient(to_bottom,#4f4f4f2e_1px,transparent_1px)] bg-[size:14px_24px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]"></div>
        <div className="absolute top-0 w-full h-full bg-primary-600/10 dark:bg-primary-500/10 blur-[120px] rounded-[100%]"></div>
        
        <div className="container px-4 relative z-10 mx-auto text-center font-sans mt-20 md:mt-0">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight mb-6">
              Travel Smart. <span className="text-primary-400">Travel Safe.</span>
            </h1>
            <p className="max-w-2xl mx-auto text-lg md:text-xl text-slate-300 mb-10">
              Your ultimate companion for secure global travel. Real-time safety insights, interactive maps, and instant alerts all in one dashboard.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link to="/signup">
                <Button size="lg" className="w-full sm:w-auto text-lg px-8 py-6 rounded-xl">
                  Get Started Free
                </Button>
              </Link>
              <a href="#features">
                <Button variant="outline" size="lg" className="w-full sm:w-auto text-lg px-8 py-6 rounded-xl border-slate-700 bg-slate-800/50 hover:bg-slate-800 text-white">
                  Explore Features
                </Button>
              </a>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-24 bg-white dark:bg-slate-950">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-slate-900 dark:text-white mb-4">Everything you need</h2>
            <p className="text-slate-600 dark:text-slate-400 max-w-xl mx-auto text-lg">
              We aggregate local safety data to provide you with peace of mind wherever you go.
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((item, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1, duration: 0.5 }}
                className="bg-slate-50 dark:bg-slate-900 p-6 rounded-2xl border border-slate-100 dark:border-slate-800 hover:shadow-lg transition-all"
              >
                <div className="w-12 h-12 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center mb-6">
                  <item.icon className="w-6 h-6 text-primary-600 dark:text-primary-400" />
                </div>
                <h3 className="text-xl font-semibold mb-3 text-slate-900 dark:text-white">{item.title}</h3>
                <p className="text-slate-600 dark:text-slate-400">{item.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
