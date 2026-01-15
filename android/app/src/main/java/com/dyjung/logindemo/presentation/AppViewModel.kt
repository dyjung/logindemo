package com.dyjung.logindemo.presentation

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

/**
 * App-level ViewModel managing global app state.
 */
@HiltViewModel
class AppViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(AppUiState())
    val uiState: StateFlow<AppUiState> = _uiState.asStateFlow()
}

/**
 * Global app UI state.
 */
data class AppUiState(
    val isLoading: Boolean = false,
    val error: String? = null
)
