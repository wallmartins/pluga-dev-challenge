import type { NextConfig } from "next";
const nextConfig: NextConfig = {
  onDemandEntries: { maxInactiveAge: 25000, pagesBufferLength: 5 },
  reactStrictMode: true,
};
export default nextConfig;
