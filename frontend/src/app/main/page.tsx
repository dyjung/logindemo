'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';

export default function MainPage() {
  const router = useRouter();
  const [user, setUser] = useState<string | null>(null);

  useEffect(() => {
    // 로그인 확인
    const token = localStorage.getItem('accessToken');
    if (!token) {
      router.push('/');
      return;
    }
    setUser('User');
  }, [router]);

  const handleLogout = () => {
    localStorage.removeItem('accessToken');
    router.push('/');
  };

  return (
    <>
      <h1>Main Page</h1>
      <p><i>Welcome to NO CSS CLUB</i></p>
      <hr />

      <h2>Login Successful!</h2>
      <p>
        Welcome, <b>{user}</b>!
        <br />
        You have successfully logged in.
      </p>

      <hr />

      <h2>Navigation</h2>
      <ul>
        <li><Link href="/main">Home</Link></li>
        <li><Link href="/main/profile">Profile</Link></li>
        <li><Link href="/main/settings">Settings</Link></li>
        <li><Link href="/main/explore">Explore</Link></li>
      </ul>

      <hr />

      <h2>Actions</h2>
      <p>
        <button type="button" onClick={handleLogout}>
          Logout
        </button>
      </p>

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
