'use client';

import { useState, useEffect } from 'react';

export default function Home() {
  const [blink, setBlink] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [visitorCount] = useState(Math.floor(Math.random() * 9000) + 1000);

  useEffect(() => {
    const blinkInterval = setInterval(() => setBlink(b => !b), 500);
    return () => clearInterval(blinkInterval);
  }, []);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    alert('로그인 기능은 iOS/Android 앱에서 이용해주세요!');
  };

  return (
    <body style={{
      margin: 0,
      padding: '20px',
      backgroundColor: '#000080',
      color: '#00FF00',
      fontFamily: 'monospace',
      minHeight: '100vh',
    }}>
      {/* 상단 타이틀 */}
      <center>
        <font color="#FFFF00" size={6}>
          <b>★ LoginDemo ★</b>
        </font>
        <br />
        <font color="#00FFFF" size={3}>
          Welcome to NO CSS CLUB
        </font>
        <hr color="#FF00FF" />
      </center>

      {/* 방문자 카운터 */}
      <center>
        <font color="#FF00FF">
          방문자: <font color="#FF0000"><b>{visitorCount.toString().padStart(6, '0')}</b></font>
        </font>
      </center>

      <br />

      {/* 메인 로그인 박스 */}
      <center>
        <table
          style={{ border: '3px double #00FF00', padding: '20px' }}
          cellPadding={10}
        >
          <tbody>
            <tr>
              <td colSpan={2} align="center">
                <font color="#00FFFF" size={5}>
                  <pre>{`
   _____
  /     \\
 | () () |
  \\  ^  /
   |||||
   |||||
                  `}</pre>
                </font>
                <font color="#FFFF00" size={4}>
                  <b>환영합니다</b>
                </font>
                <br />
                <font color="#808080">
                  계정에 로그인하세요
                </font>
              </td>
            </tr>

            <tr>
              <td colSpan={2}>
                <hr color="#00FF00" />
              </td>
            </tr>

            <tr>
              <td align="right">
                <font color="#00FF00">이메일:</font>
              </td>
              <td>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  style={{
                    backgroundColor: '#000000',
                    color: '#00FF00',
                    border: '1px solid #00FF00',
                    padding: '5px',
                    fontFamily: 'monospace',
                    width: '200px',
                  }}
                  placeholder="user@example.com"
                />
              </td>
            </tr>

            <tr>
              <td align="right">
                <font color="#00FF00">비밀번호:</font>
              </td>
              <td>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  style={{
                    backgroundColor: '#000000',
                    color: '#00FF00',
                    border: '1px solid #00FF00',
                    padding: '5px',
                    fontFamily: 'monospace',
                    width: '200px',
                  }}
                  placeholder="********"
                />
              </td>
            </tr>

            <tr>
              <td colSpan={2} align="center">
                <br />
                <input
                  type="submit"
                  value="[ 로그인 ]"
                  onClick={handleLogin}
                  style={{
                    backgroundColor: '#003300',
                    color: '#00FF00',
                    border: '2px outset #00FF00',
                    padding: '10px 30px',
                    fontFamily: 'monospace',
                    fontSize: '16px',
                    cursor: 'pointer',
                  }}
                />
              </td>
            </tr>

            <tr>
              <td colSpan={2} align="center">
                <font color="#808080" size={2}>
                  <a href="#" style={{ color: '#00FFFF' }}>비밀번호를 잊으셨나요?</a>
                </font>
              </td>
            </tr>

            <tr>
              <td colSpan={2}>
                <hr color="#808080" />
              </td>
            </tr>

            <tr>
              <td colSpan={2} align="center">
                <font color="#808080">── 또는 ──</font>
              </td>
            </tr>

            <tr>
              <td colSpan={2} align="center">
                <table>
                  <tbody>
                    <tr>
                      <td>
                        <button style={{
                          backgroundColor: '#FEE500',
                          color: '#000000',
                          border: 'none',
                          padding: '8px 15px',
                          margin: '5px',
                          cursor: 'pointer',
                          fontFamily: 'monospace',
                        }}>
                          카카오
                        </button>
                      </td>
                      <td>
                        <button style={{
                          backgroundColor: '#03C75A',
                          color: '#FFFFFF',
                          border: 'none',
                          padding: '8px 15px',
                          margin: '5px',
                          cursor: 'pointer',
                          fontFamily: 'monospace',
                        }}>
                          네이버
                        </button>
                      </td>
                      <td>
                        <button style={{
                          backgroundColor: '#000000',
                          color: '#FFFFFF',
                          border: '1px solid #FFFFFF',
                          padding: '8px 15px',
                          margin: '5px',
                          cursor: 'pointer',
                          fontFamily: 'monospace',
                        }}>
                          Apple
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
            </tr>

            <tr>
              <td colSpan={2} align="center">
                <br />
                <font color="#808080">계정이 없으신가요? </font>
                <a href="#" style={{ color: '#FFFF00' }}>회원가입</a>
              </td>
            </tr>
          </tbody>
        </table>
      </center>

      <br />
      <hr color="#FF00FF" />

      {/* 긴급연락처 */}
      <center>
        <table style={{ border: '2px dashed #FF0000', padding: '10px', backgroundColor: '#330000' }}>
          <tbody>
            <tr>
              <td align="center">
                <font color="#FFFF00">☎ 긴급연락처 ☎</font>
                <br />
                <font color={blink ? '#FF0000' : '#FFFF00'}>
                  <b>양부장: 010-2623-5585</b>
                </font>
              </td>
            </tr>
          </tbody>
        </table>
      </center>

      <br />

      {/* 하단 정보 */}
      <center>
        <hr color="#808080" />
        <font color="#808080" size={2}>
          © 2026 LoginDemo | NO CSS CLUB #0001
          <br />
          Best viewed with Netscape Navigator 4.0 @ 800x600
        </font>
        <br /><br />
        <font color="#00FF00" size={2}>
          {blink ? '🚧' : '⚠️'} Under Construction {blink ? '⚠️' : '🚧'}
        </font>
      </center>
    </body>
  );
}
