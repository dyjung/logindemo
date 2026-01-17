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
    <div style={{
      margin: 0,
      padding: '20px',
      backgroundColor: '#000080',
      color: '#00FF00',
      fontFamily: 'monospace',
      minHeight: '100vh',
    }}>
      {/* 상단 타이틀 */}
      <center>
        <span style={{ color: '#FFFF00', fontSize: '32px', fontWeight: 'bold' }}>
          ★ LoginDemo ★
        </span>
        <br />
        <span style={{ color: '#00FFFF', fontSize: '18px' }}>
          Welcome to NO CSS CLUB
        </span>
        <hr style={{ borderColor: '#FF00FF' }} />
      </center>

      {/* 방문자 카운터 */}
      <center>
        <span style={{ color: '#FF00FF' }}>
          방문자: <span style={{ color: '#FF0000', fontWeight: 'bold' }}>{visitorCount.toString().padStart(6, '0')}</span>
        </span>
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
                <span style={{ color: '#00FFFF', fontSize: '24px' }}>
                  <pre style={{ margin: 0 }}>{`   _____
  /     \\
 | () () |
  \\  ^  /
   |||||
   |||||`}</pre>
                </span>
                <br />
                <span style={{ color: '#FFFF00', fontSize: '22px', fontWeight: 'bold' }}>
                  환영합니다
                </span>
                <br />
                <span style={{ color: '#808080' }}>
                  계정에 로그인하세요
                </span>
              </td>
            </tr>

            <tr>
              <td colSpan={2}>
                <hr style={{ borderColor: '#00FF00' }} />
              </td>
            </tr>

            <tr>
              <td align="right">
                <span style={{ color: '#00FF00' }}>이메일:</span>
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
                <span style={{ color: '#00FF00' }}>비밀번호:</span>
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
                <span style={{ color: '#808080', fontSize: '12px' }}>
                  <a href="#" style={{ color: '#00FFFF' }}>비밀번호를 잊으셨나요?</a>
                </span>
              </td>
            </tr>

            <tr>
              <td colSpan={2}>
                <hr style={{ borderColor: '#808080' }} />
              </td>
            </tr>

            <tr>
              <td colSpan={2} align="center">
                <span style={{ color: '#808080' }}>── 또는 ──</span>
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
                <span style={{ color: '#808080' }}>계정이 없으신가요? </span>
                <a href="#" style={{ color: '#FFFF00' }}>회원가입</a>
              </td>
            </tr>
          </tbody>
        </table>
      </center>

      <br />
      <hr style={{ borderColor: '#FF00FF' }} />

      {/* 긴급연락처 */}
      <center>
        <table style={{ border: '2px dashed #FF0000', padding: '10px', backgroundColor: '#330000' }}>
          <tbody>
            <tr>
              <td align="center">
                <span style={{ color: '#FFFF00' }}>☎ 긴급연락처 ☎</span>
                <br />
                <span style={{ color: blink ? '#FF0000' : '#FFFF00', fontWeight: 'bold' }}>
                  양부장: 010-2623-5585
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </center>

      <br />

      {/* 하단 정보 */}
      <center>
        <hr style={{ borderColor: '#808080' }} />
        <span style={{ color: '#808080', fontSize: '12px' }}>
          © 2026 LoginDemo | NO CSS CLUB #0001
          <br />
          Best viewed with Netscape Navigator 4.0 @ 800x600
        </span>
        <br /><br />
        <span style={{ color: '#00FF00', fontSize: '12px' }}>
          {blink ? '🚧' : '⚠️'} Under Construction {blink ? '⚠️' : '🚧'}
        </span>
      </center>
    </div>
  );
}
