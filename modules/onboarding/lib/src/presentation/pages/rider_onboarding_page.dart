import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding/src/domain/repositories/company_repository.dart';
import 'package:phone_text_field/phone_text_field.dart';
import 'package:shared/shared.dart';

class RiderOnboardingPage extends StatefulWidget {
  const RiderOnboardingPage({super.key});

  @override
  State<RiderOnboardingPage> createState() => _RiderOnboardingPageState();
}

class _RiderOnboardingPageState extends State<RiderOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _registrationNumberController = TextEditingController();

  PhoneNumber? _phoneNumber;

  @override
  void dispose() {
    _registrationNumberController.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    if (_formKey.currentState?.validate() != true) return;

    // final onboardingState = context.read<OnboardingBloc>().state;

    // if (onboardingState.isIndependent && onboardingState.permitUrl == null) {
    //   return context.toast.showToast(
    //     'Please upload your solo-rider permit',
    //     type: ToastType.error,
    //   );
    // }

    // if (!onboardingState.isIndependent && onboardingState.company == null) {
    //   return context.toast.showToast(
    //     'Please select your company or check independent',
    //     type: ToastType.error,
    //   );
    // }

    context.read<OnboardingBloc>().add(
      OnboardingEvent.submitRiderOnboarding(
        phoneNumber: _phoneNumber?.completeNumber ?? '',
        registrationNumber: _registrationNumberController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == OnboardingStatus.success) {
          context.go(ModuleRoutePaths.rider);
        } else if (state.status == OnboardingStatus.error) {
          context.toast.showToast(
            state.message ?? 'An error occurred',
            type: ToastType.error,
          );
        }
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, onboardingState) {
          final selectedCompany = onboardingState.company;
          return Scaffold(
            backgroundColor: LogistixColors.background,
            body: Stack(
              children: [
                // Decorative Background
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LogistixColors.primary.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: LogistixColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.motorcycle_rounded,
                                    size: 40,
                                    color: LogistixColors.primary,
                                  ),
                                ),
                              ).animate().fade(duration: 350.ms).scale(
                                    begin: const Offset(0.85, 0.85),
                                    curve: Curves.easeOutBack,
                                  ),
                              const SizedBox(height: 24),
                              Text(
                                'Finalize Rider Profile',
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineSmall?.bold
                                    .copyWith(
                                  color: LogistixColors.text,
                                ),
                              ).animate(delay: 80.ms).fade().slideY(begin: 0.12),
                              const SizedBox(height: 8),
                              Text(
                                'Complete your account setup to start delivering packages.',
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: LogistixColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 40),
                              LogistixCard(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      PhoneTextField(
                                        initialCountryCode: 'ng',
                                        onChanged: (value) =>
                                            _phoneNumber = value,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon:
                                              Icon(Icons.phone_outlined),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller:
                                            _registrationNumberController,
                                        decoration: const InputDecoration(
                                          labelText: 'Vehicle Reg Number',
                                          prefixIcon: Icon(Icons.pin_outlined),
                                          hintText: 'e.g., KJA-1234',
                                        ),
                                        validator:
                                            FormBuilderValidators.required(),
                                        textCapitalization:
                                            TextCapitalization.characters,
                                      ),
                                      const SizedBox(height: 20),
                                      DropdownSearch<Company>(
                                        items: (String filter, _) async {
                                          final repo =
                                              context.read<CompanyRepository>();
                                          final result = await repo
                                              .getCompanies(search: filter);
                                          return result.map(
                                              (_) => const [], (r) => r.items);
                                        },
                                        compareFn: EqualityFilter<Company>(
                                          (state) => state.id,
                                        ).call,
                                        itemAsString: (company) => company.name,
                                        selectedItem: selectedCompany,
                                        suffixProps: const DropdownSuffixProps(
                                          clearButtonProps:
                                              ClearButtonProps(isVisible: true),
                                          dropdownButtonProps:
                                              DropdownButtonProps(
                                            isVisible: false,
                                          ),
                                        ),
                                        onChanged: (company) {
                                          context.read<OnboardingBloc>().add(
                                                OnboardingEvent.updateProgress(
                                                    company: company),
                                              );
                                        },
                                        decoratorProps:
                                            const DropDownDecoratorProps(
                                          decoration: InputDecoration(
                                            labelText: 'Associated Company',
                                            hintText: 'Select company...',
                                            prefixIcon:
                                                Icon(Icons.business_outlined),
                                          ),
                                        ),
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          loadingBuilder: (_, _) =>
                                              const LogistixLoadingIndicator(),
                                          searchFieldProps: const TextFieldProps(
                                            autofocus: true,
                                            autocorrect: false,
                                            decoration: InputDecoration(
                                              hintText: 'Search companies...',
                                              prefixIcon: Icon(Icons.search),
                                            ),
                                          ),
                                        ),
                                        validator: (val) => val == null
                                            ? 'Please select your company'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              BlocBuilder<OnboardingBloc, OnboardingState>(
                                builder: (context, state) {
                                  final isLoading = state.status ==
                                      OnboardingStatus.loading;
                                  return LogistixButton(
                                    label: 'COMPLETE SETUP',
                                    isLoading: isLoading,
                                    onPressed: _submitOnboarding,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
