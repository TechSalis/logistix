import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
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

  PhoneNumber? _phoneNumber;
  Company? _company;

  @override
  void dispose() {
    super.dispose();
    _registrationNumberController.dispose();
  }

  void _submitOnboarding() {
    if (_formKey.currentState?.validate() != true) return;

    // In multi-tenant mode, company selection is required
    if (!EnvConfig.instance.isSingleTenant && _company == null) {
      return;
    }

    context.read<OnboardingBloc>().add(
          OnboardingEvent.saveRiderOnboarding(
            phoneNumber: _phoneNumber?.completeNumber ?? '',
            registrationNumber: _registrationNumberController.text,
            company: _company,
          ),
        );
    
    // Navigate to complete onboarding page
    context.push(OnboardingRoutes.completeOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, onboardingState) {
        return LogistixAuthScaffold(
          header: Container(
            padding: const EdgeInsets.all(BootstrapSpacing.lg),
            decoration: BoxDecoration(
              color: LogistixColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.motorcycle_rounded,
              size: 40,
              color: LogistixColors.primary,
            ),
          ),
          title: 'Finalize Rider Profile',
          subtitle: 'Complete your account setup to start delivering packages.',
          onBack: () => context.pop(),
          footer: BootstrapButton(
            label: 'Complete Setup',
            isLoading: onboardingState.status == OnboardingStatus.loading,
            onPressed: _submitOnboarding,
          ),
          children: [
            BootstrapCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    PhoneTextField(
                      initialCountryCode: 'ng',
                      onChanged: (value) => _phoneNumber = value,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: BootstrapSpacing.lg),
                    BootstrapTextField(
                      controller: _registrationNumberController,
                      label: 'Vehicle Reg Number',
                      icon: Icons.pin_rounded,
                      hintText: 'e.g., KJA-1234',
                      validator: FormBuilderValidators.required(),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    if (!EnvConfig.instance.isSingleTenant) ...[
                      const SizedBox(height: BootstrapSpacing.lg),
                      DropdownSearch<Company>(
                        items: (String filter, _) async {
                          final repo = context.read<CompanyRepository>();
                          final result = await repo.getCompanies(
                            search: filter,
                          );
                          return result.map((_) => const [], (r) => r.items);
                        },
                        compareFn: EqualityFilter<Company>(
                          (state) => state.id,
                        ).call,
                        itemAsString: (company) => company.name,
                        selectedItem: _company,
                        onChanged: (company) => _company = company,
                        suffixProps: const DropdownSuffixProps(
                          clearButtonProps: ClearButtonProps(isVisible: true),
                          dropdownButtonProps:
                              DropdownButtonProps(isVisible: false),
                        ),
                        decoratorProps: const DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Associated Company',
                            hintText: 'Select company...',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          loadingBuilder: (_, _) =>
                              const BootstrapLoadingIndicator(),
                          searchFieldProps: const TextFieldProps(
                            autofocus: true,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: 'Search companies...',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        validator: (val) =>
                            val == null ? 'Please select your company' : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
