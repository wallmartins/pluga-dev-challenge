import { createSummariesApi, createApiClient } from "./api-client";

describe("api-client", () => {
  describe("createApiClient", () => {
    const originalEnv = process.env.NEXT_PUBLIC_API_BASE_URL;

    afterEach(() => {
      process.env.NEXT_PUBLIC_API_BASE_URL = originalEnv;
    });

    it("creates axios instance with custom baseURL when env var is set", () => {
      process.env.NEXT_PUBLIC_API_BASE_URL = "https://custom-api.com";
      const apiClient = createApiClient();
      expect(apiClient).toBeDefined();
      expect(apiClient.defaults).toBeDefined();
      expect(apiClient.defaults.baseURL).toBe("https://custom-api.com");
    });

    it("creates axios instance with default baseURL when env var is not set", () => {
      delete process.env.NEXT_PUBLIC_API_BASE_URL;
      const apiClient = createApiClient();
      expect(apiClient).toBeDefined();
      expect(apiClient.defaults).toBeDefined();
      expect(apiClient.defaults.baseURL).toBe("http://localhost:3000");
    });
  });

  describe("summariesApi.create", () => {
    it("posts to /summaries and returns data", async () => {
      const mockResponse: any = {
        id: "123",
        status: "pending",
        summary: null,
        created_at: "2024-01-01",
        original_post: "test",
      };
      const mockApiClient = {
        post: jest.fn().mockResolvedValue({ data: mockResponse }),
      };
      const api = createSummariesApi(mockApiClient as any);

      const result = await api.create({ summary: { original_post: "test" } });
      expect(result).toEqual(mockResponse);
      expect(mockApiClient.post).toHaveBeenCalledWith("/summaries", {
        summary: { original_post: "test" },
      });
    });
  });

  describe("summariesApi.getById", () => {
    it("gets from /summaries/{id} and returns data", async () => {
      const mockResponse: any = {
        id: "123",
        status: "completed",
        summary: "Summary",
        created_at: "2024-01-01",
        original_post: "test",
      };
      const mockApiClient = {
        get: jest.fn().mockResolvedValue({ data: mockResponse }),
      };
      const api = createSummariesApi(mockApiClient as any);

      const result = await api.getById("123");
      expect(result).toEqual(mockResponse);
      expect(mockApiClient.get).toHaveBeenCalledWith("/summaries/123");
    });
  });

  describe("summariesApi.list", () => {
    it("gets from /summaries and returns array", async () => {
      const mockResponse: any = [
        {
          id: "1",
          status: "completed",
          summary: "Summary 1",
          created_at: "2024-01-01",
          original_post: "test",
        },
      ];
      const mockApiClient = {
        get: jest.fn().mockResolvedValue({ data: mockResponse }),
      };
      const api = createSummariesApi(mockApiClient as any);

      const result = await api.list();
      expect(result).toEqual(mockResponse);
      expect(mockApiClient.get).toHaveBeenCalledWith("/summaries");
    });
  });

  describe("summariesApi (default export)", () => {
    it("is created with default api client", () => {
      const { create, getById, list } = require("./api-client").summariesApi;
      expect(create).toBeDefined();
      expect(getById).toBeDefined();
      expect(list).toBeDefined();
      expect(typeof create).toBe("function");
      expect(typeof getById).toBe("function");
      expect(typeof list).toBe("function");
    });
  });
});
