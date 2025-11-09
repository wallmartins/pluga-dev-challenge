"use client";

import { useEffect, useState } from "react";
import { Home } from "./home";

export function HomeClient() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return <div className="h-screen w-screen bg-white dark:bg-black" />;
  }

  return <Home />;
}
