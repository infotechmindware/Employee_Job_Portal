import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final File? businessLicense;
  final File? gstCertificate;
  final File? additionalProof;

  ProfileState({
    this.businessLicense,
    this.gstCertificate,
    this.additionalProof,
  });

  ProfileState copyWith({
    File? businessLicense,
    File? gstCertificate,
    File? additionalProof,
  }) {
    return ProfileState(
      businessLicense: businessLicense ?? this.businessLicense,
      gstCertificate: gstCertificate ?? this.gstCertificate,
      additionalProof: additionalProof ?? this.additionalProof,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => ProfileState();

  void setBusinessLicense(File? file) => state = state.copyWith(businessLicense: file);
  void setGstCertificate(File? file) => state = state.copyWith(gstCertificate: file);
  void setAdditionalProof(File? file) => state = state.copyWith(additionalProof: file);
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
