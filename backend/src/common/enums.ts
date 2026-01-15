export enum AuthenticationMethod {
  EMAIL = 'EMAIL',
  KAKAO = 'KAKAO',
  NAVER = 'NAVER',
  APPLE = 'APPLE',
  GOOGLE = 'GOOGLE',
}

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  SLEEP = 'SLEEP',
  SUSPENDED = 'SUSPENDED',
  DELETED = 'DELETED',
}

export enum Platform {
  IOS = 'iOS',
  ANDROID = 'Android',
  WEB = 'Web',
}

export enum AutoLoginFailureReason {
  NO_TOKEN = 'NO_TOKEN',
  TOKEN_EXPIRED = 'TOKEN_EXPIRED',
  TOKEN_INVALID = 'TOKEN_INVALID',
  ACCOUNT_SLEEP = 'ACCOUNT_SLEEP',
  ACCOUNT_SUSPENDED = 'ACCOUNT_SUSPENDED',
  ACCOUNT_DELETED = 'ACCOUNT_DELETED',
}
