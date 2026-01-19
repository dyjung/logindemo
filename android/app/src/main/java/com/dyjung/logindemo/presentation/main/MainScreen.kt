package com.dyjung.logindemo.presentation.main

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.dyjung.logindemo.presentation.theme.AppColors

/**
 * 메인 탭 열거형
 * iOS의 MainTab에 대응
 */
enum class MainTab(
    val title: String,
    val icon: ImageVector,
    val selectedIcon: ImageVector
) {
    EXPLORE("탐색", Icons.Outlined.LocationOn, Icons.Filled.LocationOn),
    SEARCH("검색", Icons.Outlined.Search, Icons.Filled.Search),
    SAVED("저장됨", Icons.Outlined.FavoriteBorder, Icons.Filled.Favorite),
    NOTIFICATIONS("알림", Icons.Outlined.Notifications, Icons.Filled.Notifications),
    PROFILE("프로필", Icons.Outlined.Person, Icons.Filled.Person)
}

/**
 * 메인 화면
 * iOS의 MainView에 대응
 */
@Composable
fun MainScreen(
    onLogout: () -> Unit
) {
    var selectedTab by remember { mutableStateOf(MainTab.EXPLORE) }

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = Color.White,
                tonalElevation = 8.dp
            ) {
                MainTab.entries.forEach { tab ->
                    NavigationBarItem(
                        icon = {
                            Icon(
                                imageVector = if (selectedTab == tab) tab.selectedIcon else tab.icon,
                                contentDescription = tab.title
                            )
                        },
                        label = { Text(tab.title) },
                        selected = selectedTab == tab,
                        onClick = { selectedTab = tab },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = AppColors.Primary,
                            selectedTextColor = AppColors.Primary,
                            indicatorColor = AppColors.Primary.copy(alpha = 0.1f)
                        )
                    )
                }
            }
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(AppColors.BackgroundLight)
        ) {
            when (selectedTab) {
                MainTab.EXPLORE -> ExploreTab()
                MainTab.SEARCH -> SearchTab()
                MainTab.SAVED -> SavedTab()
                MainTab.NOTIFICATIONS -> NotificationsTab()
                MainTab.PROFILE -> ProfileTab(onLogout = onLogout)
            }
        }
    }
}

@Composable
private fun ExploreTab() {
    // ExploreScreen 사용 (ViewModel과 Repository 연결)
    ExploreScreen()
}

@Composable
private fun SearchTab() {
    PlaceholderTab(
        icon = Icons.Default.Search,
        title = "검색",
        description = "원하는 장소를 검색하세요"
    )
}

@Composable
private fun SavedTab() {
    PlaceholderTab(
        icon = Icons.Default.Favorite,
        title = "저장됨",
        description = "저장한 장소를 확인하세요"
    )
}

@Composable
private fun NotificationsTab() {
    PlaceholderTab(
        icon = Icons.Default.Notifications,
        title = "알림",
        description = "새로운 알림이 없습니다"
    )
}

@Composable
private fun PlaceholderTab(
    icon: ImageVector,
    title: String,
    description: String
) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = AppColors.Primary.copy(alpha = 0.5f)
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = title,
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = AppColors.TextPrimary
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = description,
            style = MaterialTheme.typography.bodyMedium,
            color = AppColors.TextSecondary
        )
    }
}

/**
 * 프로필 탭
 * iOS의 ProfileView에 대응
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ProfileTab(onLogout: () -> Unit) {
    // Mock user data (실제 앱에서는 ViewModel에서 가져옴)
    val userName = "테스트 사용자"
    val userEmail = "test@example.com"

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        // 상단 앱바
        TopAppBar(
            title = { Text("프로필") },
            actions = {
                IconButton(onClick = { /* 설정 */ }) {
                    Icon(Icons.Default.Settings, contentDescription = "설정")
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = AppColors.BackgroundLight
            )
        )

        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            // 프로필 헤더
            ProfileHeader(
                name = userName,
                email = userEmail
            )

            Spacer(modifier = Modifier.height(24.dp))

            // 통계 섹션
            StatsSection()

            Spacer(modifier = Modifier.height(24.dp))

            // 메뉴 섹션들
            MenuSection(title = "내 활동") {
                MenuItem(
                    icon = Icons.Default.Star,
                    title = "내 리뷰",
                    iconTint = Color(0xFFFFCC00)
                )
                MenuItem(
                    icon = Icons.Default.Face,
                    title = "내 사진",
                    iconTint = AppColors.Primary
                )
                MenuItem(
                    icon = Icons.Default.Favorite,
                    title = "북마크",
                    iconTint = Color(0xFFFF9500)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            MenuSection(title = "설정") {
                MenuItem(
                    icon = Icons.Default.Notifications,
                    title = "알림 설정",
                    iconTint = Color(0xFFFF3B30)
                )
                MenuItem(
                    icon = Icons.Default.Lock,
                    title = "개인정보 보호",
                    iconTint = Color.Gray
                )
                MenuItem(
                    icon = Icons.Default.Info,
                    title = "도움말",
                    iconTint = Color(0xFF34C759)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // 로그아웃 버튼
            Button(
                onClick = onLogout,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White,
                    contentColor = Color(0xFFFF3B30)
                ),
                shape = RoundedCornerShape(12.dp),
                elevation = ButtonDefaults.buttonElevation(
                    defaultElevation = 2.dp
                )
            ) {
                Text(
                    text = "로그아웃",
                    fontWeight = FontWeight.SemiBold
                )
            }

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
private fun ProfileHeader(
    name: String,
    email: String
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 프로필 이미지
        Box(
            modifier = Modifier
                .size(80.dp)
                .clip(CircleShape)
                .background(AppColors.Primary.copy(alpha = 0.2f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = name.firstOrNull()?.uppercase() ?: "U",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = AppColors.Primary
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = name,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = AppColors.TextPrimary
        )

        Text(
            text = email,
            style = MaterialTheme.typography.bodyMedium,
            color = AppColors.TextSecondary
        )

        Spacer(modifier = Modifier.height(12.dp))

        // 프로필 수정 버튼
        TextButton(
            onClick = { /* 프로필 수정 */ },
            colors = ButtonDefaults.textButtonColors(
                containerColor = AppColors.Primary.copy(alpha = 0.1f)
            ),
            shape = RoundedCornerShape(20.dp)
        ) {
            Text(
                text = "프로필 수정",
                color = AppColors.Primary,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

@Composable
private fun StatsSection() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 16.dp)
        ) {
            StatItem(value = "12", label = "리뷰", modifier = Modifier.weight(1f))
            VerticalDivider(
                modifier = Modifier.height(40.dp),
                color = AppColors.DividerLight
            )
            StatItem(value = "48", label = "저장됨", modifier = Modifier.weight(1f))
            VerticalDivider(
                modifier = Modifier.height(40.dp),
                color = AppColors.DividerLight
            )
            StatItem(value = "5", label = "여행", modifier = Modifier.weight(1f))
        }
    }
}

@Composable
private fun StatItem(
    value: String,
    label: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = value,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = AppColors.TextPrimary
        )
        Text(
            text = label,
            style = MaterialTheme.typography.bodySmall,
            color = AppColors.TextSecondary
        )
    }
}

@Composable
private fun MenuSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Column {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold,
            color = AppColors.TextPrimary,
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 8.dp)
        )

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column {
                content()
            }
        }
    }
}

@Composable
private fun MenuItem(
    icon: ImageVector,
    title: String,
    iconTint: Color
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { /* 메뉴 클릭 */ }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = iconTint,
            modifier = Modifier.size(24.dp)
        )

        Spacer(modifier = Modifier.width(12.dp))

        Text(
            text = title,
            style = MaterialTheme.typography.bodyLarge,
            color = AppColors.TextPrimary,
            modifier = Modifier.weight(1f)
        )

        Icon(
            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
            contentDescription = null,
            tint = AppColors.TextSecondary
        )
    }
}

// MARK: - Preview

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun MainScreenPreview() {
    MaterialTheme {
        MainScreen(onLogout = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun ExploreTabPreview() {
    MaterialTheme {
        ExploreTab()
    }
}

@Preview(showBackground = true)
@Composable
private fun ProfileTabPreview() {
    MaterialTheme {
        ProfileTab(onLogout = {})
    }
}
