'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const res = await fetch('/v1/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          password,
          provider: 'EMAIL',
        }),
      });

      if (res.ok) {
        const data = await res.json();
        // 로그인 성공 - 토큰 저장 (간단히 localStorage 사용)
        if (data.accessToken) {
          localStorage.setItem('accessToken', data.accessToken);
        }
        // /main 페이지로 이동
        router.push('/main');
      } else {
        const errorData = await res.json();
        setError(errorData.message || 'Login failed. Please check your credentials.');
      }
    } catch {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <h1>LoginDemo</h1>
      <p><i>Welcome to NO CSS CLUB</i></p>
      <hr />

      <h2>About</h2>
      <p>
        This is a demo application for iOS and Android login functionality.
        <br />
        Built with <b>Next.js</b> (Frontend) + <b>NestJS</b> (Backend)
      </p>

      <hr />

      <h2>Login</h2>
      <form onSubmit={handleLogin}>
        <p>
          <label>
            Email: <input
              type="email"
              name="email"
              placeholder="user@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </label>
        </p>
        <p>
          <label>
            Password: <input
              type="password"
              name="password"
              placeholder="********"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </label>
        </p>
        <p>
          <label>
            <input type="checkbox" name="remember" /> Remember me
          </label>
        </p>
        {error && (
          <p>
            <b>Error:</b> {error}
          </p>
        )}
        <p>
          <button type="submit" disabled={loading}>
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </p>
      </form>

      <p>
        <a href="#">Forgot password?</a>
        {' | '}
        <a href="#">Sign up</a>
      </p>

      <hr />

      <h2>Social Login</h2>
      <ul>
        <li><a href="#">Login with Kakao</a></li>
        <li><a href="#">Login with Naver</a></li>
        <li><a href="#">Login with Apple</a></li>
      </ul>

      <hr />

      <h2>Links</h2>
      <ul>
        <li><a href="/api-docs" target="_blank">API Documentation (Swagger)</a></li>
        <li><a href="https://github.com/dyjung/logindemo" target="_blank">GitHub Repository</a></li>
      </ul>

      <hr />

      <h2>Emergency Contact</h2>
      <p>
        <b>Yang Bujang: 010-2623-5585</b>
      </p>

      <hr />

      <address>
        &copy; 2026 LoginDemo | NO CSS CLUB Member #0001
        <br />
        <small>Best viewed with any browser</small>
      </address>
    </>
  );
}
