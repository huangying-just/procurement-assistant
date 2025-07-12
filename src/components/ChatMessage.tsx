import React from 'react';
import { Message } from '../types';
import { User, Bot } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

interface ChatMessageProps {
  message: Message;
}

const ChatMessage: React.FC<ChatMessageProps> = ({ message }) => {
  const isUser = message.role === 'user';
  
  return (
    <div className={`flex ${isUser ? 'justify-end' : 'justify-start'} mb-4`}>
      <div className={`flex ${isUser ? 'flex-row-reverse' : 'flex-row'} items-start max-w-5xl`}>
        <div className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center ${
          isUser ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-600'
        }`}>
          {isUser ? <User size={16} /> : <Bot size={16} />}
        </div>
        
        <div className={`mx-3 px-4 py-3 rounded-lg max-w-3xl ${
          isUser 
            ? 'bg-primary-600 text-white' 
            : 'bg-gray-100 text-gray-800'
        }`}>
          {isUser ? (
            <div className="whitespace-pre-wrap">{message.content}</div>
          ) : (
            <div className="prose prose-sm max-w-none">
              <ReactMarkdown 
                remarkPlugins={[remarkGfm]}
                components={{
                  h1: ({children}) => <h1 className="text-lg font-bold mb-2">{children}</h1>,
                  h2: ({children}) => <h2 className="text-base font-bold mb-2">{children}</h2>,
                  h3: ({children}) => <h3 className="text-sm font-bold mb-1">{children}</h3>,
                  p: ({children}) => <p className="mb-2">{children}</p>,
                  ul: ({children}) => <ul className="list-disc list-inside mb-2 space-y-1">{children}</ul>,
                  ol: ({children}) => <ol className="list-decimal list-inside mb-2 space-y-1">{children}</ol>,
                  li: ({children}) => <li className="text-sm">{children}</li>,
                  strong: ({children}) => <strong className="font-semibold">{children}</strong>,
                  em: ({children}) => <em className="italic">{children}</em>,
                  code: ({children}) => <code className="bg-gray-200 px-1 py-0.5 rounded text-xs">{children}</code>,
                  pre: ({children}) => <pre className="bg-gray-200 p-2 rounded text-xs overflow-x-auto">{children}</pre>,
                  blockquote: ({children}) => <blockquote className="border-l-4 border-primary-500 pl-3 italic text-gray-600">{children}</blockquote>,
                }}
              >
                {message.content}
              </ReactMarkdown>
            </div>
          )}
          <div className={`text-xs mt-2 ${
            isUser ? 'text-primary-100' : 'text-gray-500'
          }`}>
            {message.timestamp.toLocaleTimeString('zh-CN', {
              hour: '2-digit',
              minute: '2-digit'
            })}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChatMessage; 