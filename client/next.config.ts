const nextConfig = {
  onDemandEntries: {
    maxInactiveAge: 120000,
    pagesBufferLength: 10,
  },
  webpackDevMiddleware: (config: any) => {
    config.watchOptions = {
      poll: 1000,
      aggregateTimeout: 300,
    };
    return config;
  },
};

export default nextConfig;
