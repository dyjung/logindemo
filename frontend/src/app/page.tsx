'use client';

import { useState, useEffect } from 'react';

interface HealthStatus {
  status: string;
  timestamp: string;
}

export default function Home() {
  const [health, setHealth] = useState<HealthStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Production: 빈 문자열 (상대 경로 사용, Nginx가 프록시)
  // Development: http://localhost:3000
  const API_URL = process.env.NEXT_PUBLIC_API_URL || '';

  useEffect(() => {
    checkHealth();
  }, []);

  const checkHealth = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/health`);
      if (!res.ok) throw new Error('API 연결 실패');
      const data = await res.json();
      setHealth(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : '알 수 없는 오류');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="min-h-screen bg-gray-100 flex flex-col items-center justify-center p-8">
      <div className="bg-white rounded-2xl shadow-lg p-8 max-w-md w-full">
        <h1 className="text-3xl font-bold text-center text-gray-800 mb-2">
          LoginDemo
        </h1>
        <p className="text-gray-500 text-center mb-8">
          Next.js + NestJS
        </p>

        {/* API 상태 카드 */}
        <div className="bg-gray-50 rounded-xl p-6 mb-6">
          <h2 className="text-lg font-semibold text-gray-700 mb-4">
            API 서버 상태
          </h2>

          {loading ? (
            <div className="flex items-center justify-center py-4">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            </div>
          ) : error ? (
            <div className="bg-red-100 text-red-700 p-4 rounded-lg">
              <p className="font-medium">연결 실패</p>
              <p className="text-sm">{error}</p>
            </div>
          ) : health ? (
            <div className="bg-green-100 text-green-700 p-4 rounded-lg">
              <p className="font-medium flex items-center gap-2">
                <span className="w-3 h-3 bg-green-500 rounded-full"></span>
                {health.status === 'ok' ? '정상 작동' : health.status}
              </p>
              <p className="text-sm mt-1">
                {new Date(health.timestamp).toLocaleString('ko-KR')}
              </p>
            </div>
          ) : null}
        </div>

        {/* 새로고침 버튼 */}
        <button
          onClick={checkHealth}
          disabled={loading}
          className="w-full bg-blue-500 hover:bg-blue-600 disabled:bg-blue-300 text-white font-medium py-3 px-4 rounded-xl transition-colors"
        >
          {loading ? '확인 중...' : '다시 확인'}
        </button>

        {/* API URL 표시 */}
        <p className="text-xs text-gray-400 text-center mt-4">
          API: {API_URL}
        </p>
      </div>

      {/* 링크 */}
      <div className="mt-8 flex gap-4 text-sm">
        <a
          href={`${API_URL}/api`}
          target="_blank"
          rel="noopener noreferrer"
          className="text-blue-500 hover:underline"
        >
          Swagger 문서
        </a>
        <span className="text-gray-300">|</span>
        <a
          href="https://github.com/dyjung/logindemo-backend"
          target="_blank"
          rel="noopener noreferrer"
          className="text-blue-500 hover:underline"
        >
          GitHub
        </a>
      </div>
    </main>
  );
}
