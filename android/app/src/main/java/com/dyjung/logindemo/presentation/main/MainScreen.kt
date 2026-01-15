package com.dyjung.logindemo.presentation.main

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector

/**
 * Main screen with bottom navigation.
 */
@Composable
fun MainScreen(
    onLogout: () -> Unit
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf(
        TabItem("탐색", Icons.Default.Explore),
        TabItem("검색", Icons.Default.Search),
        TabItem("저장", Icons.Default.Bookmark),
        TabItem("알림", Icons.Default.Notifications),
        TabItem("프로필", Icons.Default.Person)
    )

    Scaffold(
        bottomBar = {
            NavigationBar {
                tabs.forEachIndexed { index, tab ->
                    NavigationBarItem(
                        icon = { Icon(tab.icon, contentDescription = tab.title) },
                        label = { Text(tab.title) },
                        selected = selectedTab == index,
                        onClick = { selectedTab = index }
                    )
                }
            }
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when (selectedTab) {
                0 -> ExploreTab()
                1 -> SearchTab()
                2 -> SavedTab()
                3 -> NotificationsTab()
                4 -> ProfileTab(onLogout = onLogout)
            }
        }
    }
}

@Composable
private fun ExploreTab() {
    CenteredText("탐색")
}

@Composable
private fun SearchTab() {
    CenteredText("검색")
}

@Composable
private fun SavedTab() {
    CenteredText("저장")
}

@Composable
private fun NotificationsTab() {
    CenteredText("알림")
}

@Composable
private fun ProfileTab(onLogout: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = androidx.compose.ui.Alignment.CenterHorizontally
    ) {
        Text("프로필", style = MaterialTheme.typography.headlineMedium)
        androidx.compose.foundation.layout.Spacer(modifier = Modifier.height(androidx.compose.ui.unit.dp.times(24)))
        Button(onClick = onLogout) {
            Text("로그아웃")
        }
    }
}

@Composable
private fun CenteredText(text: String) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = androidx.compose.ui.Alignment.Center
    ) {
        Text(text, style = MaterialTheme.typography.headlineMedium)
    }
}

private data class TabItem(
    val title: String,
    val icon: ImageVector
)
