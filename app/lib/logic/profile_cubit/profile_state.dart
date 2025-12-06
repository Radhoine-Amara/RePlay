import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/models/item_model.dart';

/// Base class for all profile states.
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before profile is loaded.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state during profile operations.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile data loaded successfully.
class ProfileLoaded extends ProfileState {
  final UserModel user;
  final List<ItemModel> myListings;
  final List<ItemModel> myFavorites;

  const ProfileLoaded({
    required this.user,
    this.myListings = const [],
    this.myFavorites = const [],
  });

  @override
  List<Object?> get props => [
    user.userId,
    myListings.length,
    myFavorites.length,
  ];

  /// Create a copy with updated values.
  ProfileLoaded copyWith({
    UserModel? user,
    List<ItemModel>? myListings,
    List<ItemModel>? myFavorites,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      myListings: myListings ?? this.myListings,
      myFavorites: myFavorites ?? this.myFavorites,
    );
  }
}

/// Profile is being updated.
class ProfileUpdating extends ProfileState {
  final UserModel user;

  const ProfileUpdating(this.user);

  @override
  List<Object?> get props => [user.userId];
}

/// Profile was updated successfully.
class ProfileUpdated extends ProfileState {
  final UserModel user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user.userId];
}

/// An error occurred during profile operations.
class ProfileError extends ProfileState {
  final String message;
  final UserModel? user; // Keep previous user data if available

  const ProfileError(this.message, {this.user});

  @override
  List<Object?> get props => [message, user?.userId];
}
