import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
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

  Company? _company;
  PhoneNumber? _phoneNumber;

  @override
  void dispose() {
    super.dispose();
    _registrationNumberController.dispose();
  }

  void _submitOnboarding() {
    if (_formKey.currentState?.validate() != true || _company == null) return;

    context.read<OnboardingBloc>().add(
      OnboardingEvent.saveRiderOnboarding(
        phoneNumber: _phoneNumber?.completeNumber ?? '',
        registrationNumber: _registrationNumberController.text,
        company: _company!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, onboardingState) {
        return Scaffold(
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
                    color: LogistixColors.primary.withOpacity(0.04),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: LogistixSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: LogistixSpacing.xs),
                            Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      LogistixSpacing.lg,
                                    ),
                                    decoration: BoxDecoration(
                                      color: LogistixColors.primary.withOpacity(
                                        0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.motorcycle_rounded,
                                      size: 40,
                                      color: LogistixColors.primary,
                                    ),
                                  ),
                                )
                                .animate()
                                .fade(duration: 350.ms)
                                .scale(
                                  begin: const Offset(0.85, 0.85),
                                  curve: Curves.easeOutBack,
                                ),
                            const SizedBox(height: LogistixSpacing.lg),
                            Text(
                              'Finalize Rider Profile',
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineSmall?.bold
                                  .copyWith(color: LogistixColors.text),
                            ).animate(delay: 80.ms).fade().slideY(begin: 0.12),
                            const SizedBox(height: LogistixSpacing.xs),
                            Text(
                              'Complete your account setup to start delivering packages.',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: LogistixColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: LogistixSpacing.xxl),
                            LogistixCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    PhoneTextField(
                                      initialCountryCode: 'ng',
                                      onChanged: (value) {
                                        _phoneNumber = value;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                      ),
                                    ),
                                    const SizedBox(height: LogistixSpacing.lg),
                                  LogistixTextField(
                                    controller: _registrationNumberController,
                                    label: 'Vehicle Reg Number',
                                    icon: Icons.pin_rounded,
                                    hintText: 'e.g., KJA-1234',
                                    validator: FormBuilderValidators.required(),
                                    textCapitalization: TextCapitalization.characters,
                                  ),
                                    const SizedBox(height: LogistixSpacing.lg),
                                    DropdownSearch<Company>(
                                      items: (String filter, _) async {
                                        final repo = context
                                            .read<CompanyRepository>();
                                        final result = await repo.getCompanies(
                                          search: filter,
                                        );
                                        return result.map(
                                          (_) => const [],
                                          (r) => r.items,
                                        );
                                      },
                                      compareFn: EqualityFilter<Company>(
                                        (state) => state.id,
                                      ).call,
                                      itemAsString: (company) => company.name,
                                      selectedItem: _company,
                                      suffixProps: const DropdownSuffixProps(
                                        clearButtonProps: ClearButtonProps(
                                          isVisible: true,
                                        ),
                                        dropdownButtonProps:
                                            DropdownButtonProps(
                                              isVisible: false,
                                            ),
                                      ),
                                      onChanged: (company) {
                                        _company = company;
                                      },
                                      decoratorProps:
                                          const DropDownDecoratorProps(
                                            decoration: InputDecoration(
                                              labelText: 'Associated Company',
                                              hintText: 'Select company...',
                                              prefixIcon: Icon(
                                                Icons.business_outlined,
                                              ),
                                            ),
                                          ),
                                      popupProps: PopupProps.menu(
                                        showSearchBox: true,
                                        loadingBuilder: (_, _) {
                                          return const LogistixLoadingIndicator();
                                        },
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
                            const SizedBox(height: LogistixSpacing.xl),
                            BlocBuilder<OnboardingBloc, OnboardingState>(
                              builder: (context, state) {
                                final isLoading =
                                    state.status == OnboardingStatus.loading;

                                return LogistixButton(
                                  label: 'Complete Setup',
                                  isLoading: isLoading,
                                  onPressed: _submitOnboarding,
                                );
                              },
                            ),
                            const SizedBox(height: LogistixSpacing.lg),
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
    );
  }
}
