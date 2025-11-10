import axios from "axios";
import type {
  CreateSummaryPayload,
  SummaryResponse,
  SummarysListResponse,
} from "./types";

export const createApiClient = () => {
  const apiBaseUrl =
    process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3000";
  return axios.create({
    baseURL: apiBaseUrl,
    headers: {
      "Content-Type": "application/json",
    },
  });
};

const api = createApiClient();

export const createSummariesApi = (apiClient = api) => ({
  create: async (payload: CreateSummaryPayload): Promise<SummaryResponse> => {
    const { data } = await apiClient.post<SummaryResponse>(
      "/summaries",
      payload
    );
    return data;
  },

  getById: async (id: string): Promise<SummaryResponse> => {
    const { data } = await apiClient.get<SummaryResponse>(`/summaries/${id}`);
    return data;
  },

  list: async (): Promise<SummarysListResponse> => {
    const { data } = await apiClient.get<SummarysListResponse>("/summaries");
    return data;
  },
});

export const summariesApi = createSummariesApi();
