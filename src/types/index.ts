export interface Message {
  id: string;
  content: string;
  role: 'user' | 'assistant';
  timestamp: Date;
}

export interface ChatResponse {
  answer: string;
  conversation_id: string;
  message_id: string;
}

export interface StreamingResponse {
  event: string;
  data: {
    answer?: string;
    conversation_id?: string;
    message_id?: string;
  };
}

export interface DifyConfig {
  apiUrl: string;
  apiKey: string;
}

export interface SuggestedQuestion {
  id: string;
  text: string;
} 