import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "LoginDemo",
  description: "Next.js + NestJS Demo Application - NO CSS CLUB Member",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
