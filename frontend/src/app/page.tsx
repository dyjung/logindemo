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
  const [blink, setBlink] = useState(true);
  const [visitorCount] = useState(Math.floor(Math.random() * 9000) + 1000);

  const API_URL = process.env.NEXT_PUBLIC_API_URL || '';

  useEffect(() => {
    checkHealth();
    const blinkInterval = setInterval(() => setBlink(b => !b), 500);
    return () => clearInterval(blinkInterval);
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

  const asciiLogo = `
    ██╗      ██████╗  ██████╗ ██╗███╗   ██╗
    ██║     ██╔═══██╗██╔════╝ ██║████╗  ██║
    ██║     ██║   ██║██║  ███╗██║██╔██╗ ██║
    ██║     ██║   ██║██║   ██║██║██║╚██╗██║
    ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║
    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝
    ██████╗ ███████╗███╗   ███╗ ██████╗
    ██╔══██╗██╔════╝████╗ ████║██╔═══██╗
    ██║  ██║█████╗  ██╔████╔██║██║   ██║
    ██║  ██║██╔══╝  ██║╚██╔╝██║██║   ██║
    ██████╔╝███████╗██║ ╚═╝ ██║╚██████╔╝
    ╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝
  `;

  const asciiWelcome = `
  ╔══════════════════════════════════════════════════════════════╗
  ║  ★ ☆ ★ ☆ ★   W E L C O M E   ★ ☆ ★ ☆ ★                      ║
  ║                                                              ║
  ║     ♣ 환 영 합 니 다 ♣                                       ║
  ║                                                              ║
  ║  ┌──────────────────────────────────────────────────────┐   ║
  ║  │  본 서비스는 LoginDemo 입니다.                       │   ║
  ║  │  Next.js + NestJS 기반으로 제작되었습니다.           │   ║
  ║  └──────────────────────────────────────────────────────┘   ║
  ╚══════════════════════════════════════════════════════════════╝
  `;

  const asciiCat = `
    /\\_/\\
   ( o.o )
    > ^ <
   /|   |\\
  (_|   |_)
  `;

  const asciiComputer = `
   .---.
  /     \\
  \\.@-@./
  /\`\\_/\`\\
 //  _  \\\\
| \\     )|_
/\`\\_\`>  <_/ \\
\\__/'---'\\__/
  `;

  // 스노클링하는 사람 ASCII 아트 (사진 기반)
  const asciiSnorkeler = `
                    .-~~~-.
                   /       \\
      .---.       (  ^   ^  )      ~~~
     / o o \\       \\  ___  /    ~~    ~~
    |  ___  |       '-----'   ~  BEACH  ~
     \\_____/    .--./     \\.--.   ~~   ~~
       |||     / .-.|  ^_^ |.-. \\    ~~~
       |||    |  \\  | \\___/|  /  |
  ~^~^~|||~^~ |   \\_|      |_/   |  ~^~^~
       |||     \\    '.____.'    /
  ╔════════════════════════════════════════╗
  ║     ~~ 스노클링 마스터 양부장 ~~      ║
  ║                                        ║
  ║   .-=*=-.    산호를 들고 포즈~    .-=*=-. ║
  ║  ( o  o )    해변에서 행복!     ( o  o )║
  ║   \\    /                         \\    / ║
  ║    '=='      🏖️  🐚  🦀  🐠      '=='  ║
  ╚════════════════════════════════════════╝

       \\\\|//        (\\       /)
        \\|/          \\\\     //
    .-\`\`\`\`\`-.        )\\   /(
   /  ^ _ ^  \\      /  \\_/  \\
  |  (o   o)  |    |  <@ @>  |
  |    ___    |     \\  ===  /
   \\  \\___/  /       '.___.'
    \`-.___.-'          |
        |            .-|-.
   .----+----.      /  |  \\
  /     |     \\    |   |   |
 |  ♥  산호  ♥ |   | 스노클 |
  \\     |     /     \\  |  /
   '----+----'       '-+-'
        |              |
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       🌊  해변의 추억  🌊
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  `;

  return (
    <main
      style={{
        minHeight: '100vh',
        backgroundColor: '#000080',
        color: '#00FF00',
        fontFamily: '"DungGeunMo", "Courier New", monospace',
        padding: '20px',
        overflow: 'auto',
      }}
    >
      {/* 스타일 삽입 */}
      <style jsx global>{`
        @import url('https://cdn.jsdelivr.net/gh/projectnoonnu/noonfonts_2107@1.0/DungGeunMo.woff2');
        @font-face {
          font-family: 'DungGeunMo';
          src: url('https://cdn.jsdelivr.net/gh/projectnoonnu/noonfonts_2107@1.0/DungGeunMo.woff2') format('woff2');
          font-weight: normal;
          font-style: normal;
        }
        body {
          margin: 0;
          padding: 0;
        }
        ::selection {
          background: #FF00FF;
          color: #FFFF00;
        }
        @keyframes rainbow {
          0% { color: #FF0000; }
          14% { color: #FF7F00; }
          28% { color: #FFFF00; }
          42% { color: #00FF00; }
          57% { color: #0000FF; }
          71% { color: #4B0082; }
          85% { color: #9400D3; }
          100% { color: #FF0000; }
        }
        @keyframes marquee {
          0% { transform: translateX(100%); }
          100% { transform: translateX(-100%); }
        }
      `}</style>

      {/* 상단 마퀴 */}
      <div style={{
        backgroundColor: '#FF00FF',
        color: '#FFFF00',
        padding: '10px',
        overflow: 'hidden',
        whiteSpace: 'nowrap',
        marginBottom: '20px',
      }}>
        <span style={{
          display: 'inline-block',
          animation: 'marquee 15s linear infinite',
        }}>
          ★☆★☆ 환영합니다! LoginDemo에 오신 것을 환영합니다! ★☆★☆
          NO CSS CLUB 회원 여러분 안녕하세요! ★☆★☆
          1990년대 감성을 느껴보세요! ★☆★☆
          방문자 여러분 감사합니다! ★☆★☆
        </span>
      </div>

      {/* ASCII 로고 */}
      <pre style={{
        color: '#00FFFF',
        textAlign: 'center',
        fontSize: '10px',
        lineHeight: '1.1',
        textShadow: '0 0 10px #00FFFF',
      }}>
        {asciiLogo}
      </pre>

      {/* 환영 박스 */}
      <pre style={{
        color: '#FFFF00',
        textAlign: 'center',
        fontSize: '12px',
        marginTop: '20px',
      }}>
        {asciiWelcome}
      </pre>

      {/* 메인 ASCII 아트 - 스노클링 양부장 */}
      <div style={{
        textAlign: 'center',
        margin: '30px auto',
        padding: '20px',
        border: '4px double #FF00FF',
        backgroundColor: 'rgba(0, 0, 128, 0.8)',
        maxWidth: '600px',
      }}>
        <div style={{
          color: '#00FFFF',
          fontSize: '20px',
          marginBottom: '15px',
          textShadow: '0 0 10px #00FFFF',
        }}>
          ★☆★ 오늘의 주인공 ★☆★
        </div>
        <pre style={{
          color: '#00FF00',
          fontSize: '11px',
          lineHeight: '1.2',
          textAlign: 'left',
          display: 'inline-block',
          textShadow: '0 0 5px #00FF00',
        }}>
          {asciiSnorkeler}
        </pre>
        <div style={{
          color: '#FF00FF',
          fontSize: '14px',
          marginTop: '15px',
          animation: 'rainbow 3s linear infinite',
        }}>
          ～ 바다를 사랑하는 양부장님 ～
        </div>
      </div>

      {/* 방문자 카운터 */}
      <div style={{
        textAlign: 'center',
        margin: '20px 0',
        color: '#FF00FF',
      }}>
        <span style={{ fontSize: '20px' }}>📟 </span>
        <span style={{
          backgroundColor: '#000000',
          border: '3px ridge #808080',
          padding: '5px 15px',
          color: '#FF0000',
          fontWeight: 'bold',
        }}>
          VISITOR: {visitorCount.toString().padStart(6, '0')}
        </span>
        <span style={{ fontSize: '20px' }}> 📟</span>
      </div>

      {/* 중앙 컨텐츠 */}
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        gap: '40px',
        flexWrap: 'wrap',
        margin: '30px 0',
      }}>
        {/* 왼쪽 ASCII 아트 */}
        <pre style={{
          color: '#FF6600',
          fontSize: '14px',
          textShadow: '0 0 5px #FF6600',
        }}>
          {asciiCat}
        </pre>

        {/* API 상태 박스 */}
        <div style={{
          border: '3px double #00FF00',
          padding: '20px',
          minWidth: '300px',
        }}>
          <div style={{
            color: '#FFFF00',
            textAlign: 'center',
            marginBottom: '15px',
            fontSize: '18px',
          }}>
            ═══ API 서버 상태 ═══
          </div>

          {loading ? (
            <div style={{ color: '#FFFF00', textAlign: 'center' }}>
              {blink ? '▓▓▓ 로딩중... ▓▓▓' : '░░░ 로딩중... ░░░'}
            </div>
          ) : error ? (
            <div style={{
              color: '#FF0000',
              textAlign: 'center',
              border: '1px solid #FF0000',
              padding: '10px',
            }}>
              ╔═══════════════════╗<br/>
              ║  ✖ 연결 실패 ✖   ║<br/>
              ╚═══════════════════╝<br/>
              {error}
            </div>
          ) : health ? (
            <div style={{ textAlign: 'center' }}>
              <div style={{
                color: '#00FF00',
                animation: 'rainbow 3s linear infinite',
                fontSize: '16px',
              }}>
                ╔═══════════════════╗<br/>
                ║  ✔ 정상 작동 ✔   ║<br/>
                ╚═══════════════════╝
              </div>
              <div style={{ color: '#00FFFF', marginTop: '10px' }}>
                ⏰ {new Date(health.timestamp).toLocaleString('ko-KR')}
              </div>
            </div>
          ) : null}

          {/* 새로고침 버튼 */}
          <button
            onClick={checkHealth}
            disabled={loading}
            style={{
              marginTop: '15px',
              width: '100%',
              padding: '10px',
              backgroundColor: '#000000',
              color: '#00FF00',
              border: '2px outset #00FF00',
              cursor: 'pointer',
              fontFamily: 'inherit',
              fontSize: '14px',
            }}
            onMouseOver={(e) => {
              e.currentTarget.style.backgroundColor = '#003300';
            }}
            onMouseOut={(e) => {
              e.currentTarget.style.backgroundColor = '#000000';
            }}
          >
            [ 다시 확인 ]
          </button>
        </div>

        {/* 오른쪽 ASCII 아트 */}
        <pre style={{
          color: '#FF00FF',
          fontSize: '12px',
          textShadow: '0 0 5px #FF00FF',
        }}>
          {asciiComputer}
        </pre>
      </div>

      {/* 메뉴 */}
      <div style={{
        textAlign: 'center',
        margin: '30px 0',
        color: '#00FFFF',
      }}>
        <div style={{ marginBottom: '10px' }}>
          ╔═══════════════════════════════════════╗
        </div>
        <div>║
          <a href={`${API_URL}/api-docs`} target="_blank" rel="noopener noreferrer"
            style={{ color: '#FFFF00', textDecoration: 'none', margin: '0 10px' }}>
            [1] Swagger 문서
          </a>
          |
          <a href="https://github.com/dyjung/logindemo" target="_blank" rel="noopener noreferrer"
            style={{ color: '#FFFF00', textDecoration: 'none', margin: '0 10px' }}>
            [2] GitHub
          </a>
          ║
        </div>
        <div style={{ marginTop: '10px' }}>
          ╚═══════════════════════════════════════╝
        </div>
      </div>

      {/* 구분선 */}
      <div style={{
        textAlign: 'center',
        color: '#FF00FF',
        margin: '20px 0',
      }}>
        ★·.·´¯`·.·★ ═══════════════════════════════════ ★·.·´¯`·.·★
      </div>

      {/* 긴급연락처 */}
      <div style={{
        textAlign: 'center',
        color: '#FF0000',
        fontSize: '18px',
        border: '2px dashed #FF0000',
        padding: '15px',
        margin: '20px auto',
        maxWidth: '400px',
        backgroundColor: '#330000',
      }}>
        <div style={{ color: '#FFFF00', marginBottom: '5px' }}>
          ☎ 긴급연락처 ☎
        </div>
        <div style={{
          color: blink ? '#FF0000' : '#FFFF00',
          fontWeight: 'bold',
        }}>
          양부장: 010-2623-5585
        </div>
      </div>

      {/* 하단 정보 */}
      <div style={{
        textAlign: 'center',
        marginTop: '40px',
        color: '#808080',
        fontSize: '12px',
      }}>
        <div>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</div>
        <div style={{ margin: '10px 0' }}>
          © 2026 LoginDemo. All Rights Reserved.
        </div>
        <div>
          Made with ♥ by DY Jung | NO CSS CLUB 회원번호 #0001
        </div>
        <div style={{ marginTop: '10px', color: '#00FF00' }}>
          Best viewed with Netscape Navigator 4.0 @ 800x600
        </div>
        <div>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</div>
      </div>

      {/* 하단 ASCII 아트 */}
      <pre style={{
        textAlign: 'center',
        color: '#00FF00',
        fontSize: '10px',
        marginTop: '20px',
      }}>
{`
   _____                      _   _
  / ____|                    | | (_)
 | |      ___  _ __  _ __   ___  ___| |_ _  ___  _ __
 | |     / _ \\| '_ \\| '_ \\ / _ \\/ __| __| |/ _ \\| '_ \\
 | |____| (_) | | | | | | |  __/ (__| |_| | (_) | | | |
  \\_____|\\___/|_| |_|_| |_|\\___|\\___|\\__|_|\\___/|_| |_|

`}
      </pre>

      {/* GIF 느낌의 움직이는 요소들 */}
      <div style={{
        position: 'fixed',
        bottom: '20px',
        right: '20px',
        fontSize: '30px',
        animation: 'rainbow 2s linear infinite',
      }}>
        {blink ? '🌟' : '✨'}
      </div>

      <div style={{
        position: 'fixed',
        bottom: '20px',
        left: '20px',
        fontSize: '30px',
      }}>
        {blink ? '🚧' : '⚠️'} Under Construction {blink ? '⚠️' : '🚧'}
      </div>
    </main>
  );
}
