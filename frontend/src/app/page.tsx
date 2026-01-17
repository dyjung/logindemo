export default function Home() {
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
      <form>
        <p>
          <label>
            Email: <input type="email" name="email" placeholder="user@example.com" />
          </label>
        </p>
        <p>
          <label>
            Password: <input type="password" name="password" placeholder="********" />
          </label>
        </p>
        <p>
          <label>
            <input type="checkbox" name="remember" /> Remember me
          </label>
        </p>
        <p>
          <button type="submit">Login</button>
          <br />
          <small>(Please use iOS/Android app for actual login)</small>
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
