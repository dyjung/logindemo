package com.dyjung.logindemo.presentation.main

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dyjung.logindemo.domain.model.Place
import com.dyjung.logindemo.domain.model.RecommendedPlace
import com.dyjung.logindemo.domain.repository.PlaceRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * 탐색 화면 ViewModel
 * iOS의 ExploreViewModel에 대응
 */
@HiltViewModel
class ExploreViewModel @Inject constructor(
    private val placeRepository: PlaceRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ExploreUiState())
    val uiState: StateFlow<ExploreUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        loadRecommendedPlaces()
        loadPopularPlaces()
    }

    private fun loadRecommendedPlaces() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoadingRecommended = true) }

            placeRepository.getRecommendedPlaces()
                .onSuccess { places ->
                    _uiState.update {
                        it.copy(
                            recommendedPlaces = places,
                            isLoadingRecommended = false,
                            recommendedError = null
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isLoadingRecommended = false,
                            recommendedError = error.message
                        )
                    }
                }
        }
    }

    private fun loadPopularPlaces() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoadingPopular = true) }

            placeRepository.getPopularPlaces()
                .onSuccess { places ->
                    _uiState.update {
                        it.copy(
                            popularPlaces = places,
                            isLoadingPopular = false,
                            popularError = null
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isLoadingPopular = false,
                            popularError = error.message
                        )
                    }
                }
        }
    }

    fun refresh() {
        loadData()
    }
}

data class ExploreUiState(
    val recommendedPlaces: List<RecommendedPlace> = emptyList(),
    val popularPlaces: List<Place> = emptyList(),
    val isLoadingRecommended: Boolean = false,
    val isLoadingPopular: Boolean = false,
    val recommendedError: String? = null,
    val popularError: String? = null
) {
    val isLoading: Boolean
        get() = isLoadingRecommended || isLoadingPopular

    val hasError: Boolean
        get() = recommendedError != null || popularError != null
}
