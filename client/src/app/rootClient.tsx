"use client";

import { ReactNode } from "react";
import { ThemeProvider } from "@/lib/theme-context";
import { QueryProvider } from "@/lib/query-provider";

export function RootClient({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider>
      <QueryProvider>{children}</QueryProvider>
    </ThemeProvider>
  );
}
