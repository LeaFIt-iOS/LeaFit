import SwiftUI
import SwiftData

struct MainMenuView: View {
    @StateObject private var categoriesViewModel: CategoriesViewModel
    
    @State private var searchPlaceholder = ""
    @State private var showAddCategory = false
    @State private var newCategoryName: String = ""
    @State private var showRenameCategory = false
    @State private var renameCategoryName: String = ""
    @State private var categoryToRename: PlantCategory?
    @State private var showEditSheet = false
    @State private var selectedCategory: PlantCategory?
    @State private var isEditMode = false
    
    @Environment(\.modelContext) private var modelContext
    
    init() {
        let viewModel = CategoriesViewModel()
        _categoriesViewModel = StateObject(wrappedValue: viewModel)
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(hex: "428D6D")]
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = UIColor(hex: "BEDCBA")
        UIToolbar.appearance().standardAppearance = toolbarAppearance
        UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
    }
    
    var body: some View {
        NavigationStack {
            let filtered = categoriesViewModel.filteredCategories(searchText: searchPlaceholder)
            let isSearchingWithNoResults = !searchPlaceholder.isEmpty && filtered.isEmpty && !categoriesViewModel.allCategories.isEmpty
            
            VStack(spacing: 0) {
                if isSearchingWithNoResults {
                    VStack {
                        Spacer()
                        Image("SearchErrorLogo")
                        Text("No Results Found")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.gray)
                        Text("Check spelling or try a new search")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(LeaFitColors.background)
                } else {
                    List {
                        NavigationLink(destination: PlantListView(plants: categoriesViewModel.allPlants, title: "All Plants")) {
                            HStack {
                                Image(systemName: "apple.meditate")
                                Text("All Plants")
                                    .foregroundColor(isEditMode ? .gray : .primary)
                                    .bold()
                                Spacer()
                                Text("\(categoriesViewModel.allPlants.count)")
                            }
                            .padding(.vertical, 4)
                            .bold()
                        }
                        .listRowBackground(Color(hex: "FAFFF9"))
                        .disabled(isEditMode)
                        
                        Button(action: {
                            if !isEditMode {
                                showAddCategory.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .bold()
                                Text("Add Categories")
                                    .foregroundColor(isEditMode ? .gray : .primary)
                                    .bold()
                            }
                        }
                        .disabled(isEditMode)
                        
                        .alert("New Category", isPresented: $showAddCategory) {
                            TextField("Add a new category", text: $newCategoryName)
                                .foregroundColor(.primary)
                            Button("Cancel", role: .cancel) {
                                newCategoryName = ""
                            }
                            Button("Save") {
                                if !newCategoryName.isEmpty && !categoriesViewModel.categoryExists(name: newCategoryName) {
                                    categoriesViewModel.addCategory(name: newCategoryName, plants: [])
                                    newCategoryName = ""
                                }
                            }
                            .disabled(newCategoryName.isEmpty || newCategoryName.count > 24 || categoriesViewModel.categoryExists(name: newCategoryName))
                        } message: {
                            if newCategoryName.count > 24 {
                                Text("Category name must be 24 characters or less")
                            } else if categoriesViewModel.categoryExists(name: newCategoryName) {
                                Text("A category with this name already exists")
                            }
                        }
                        .listRowBackground(Color(hex: "FAFFF9"))
                        
                        Section(header: Text("My Categories")
                            .font(.headline)
                            .foregroundColor(.primary)) {
                                
                                if filtered.isEmpty && !searchPlaceholder.isEmpty {
                                    Text("No results found")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(filtered) { category in
                                        HStack {
                                            NavigationLink(destination: PlantListView(plants: category.plants, title: category.name)) {
                                                HStack {
                                                    Image(systemName: "leaf")
                                                        .bold()
                                                    Text(category.name)
                                                        .foregroundColor(.primary)
                                                        .bold()
                                                    Spacer()
                                                }
                                                .padding(.vertical, 4)
                                            }
                                            .disabled(isEditMode)
                                            
                                            if isEditMode {
                                                Button(action: {
                                                    selectedCategory = category
                                                    showEditSheet = true
                                                }) {
                                                    Image(systemName: "ellipsis.circle")
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                                
                                                Divider()
                                                    .frame(height: 20)
                                                
                                                Image(systemName: "line.3.horizontal")
                                                    .foregroundColor(.gray)
                                            } else {
                                                Text("\(category.plants.count)")
                                            }
                                        }
                                        .listRowBackground(Color(hex: "FAFFF9"))
                                    }
                                }
                            }
                    }
                    .background(LeaFitColors.background)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("LeaFit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation {
                            isEditMode.toggle()
                        }
                    }
                }
            }
            .foregroundColor(Color(hex: "428D6D"))
            .searchable(text: $searchPlaceholder, placement: .navigationBarDrawer(displayMode: .automatic))
            .onAppear {
                categoriesViewModel.setModelContext(modelContext)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        NavigationLink(destination: InformationView()) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(Color(hex: "428D6D"))
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: CameraRulesView()) {
                            Image(systemName: "camera")
                                .foregroundStyle(Color(hex: "428D6D"))
                        }
                    }
                }
            }
            .actionSheet(isPresented: $showEditSheet) {
                ActionSheet(
                    title: Text("\(selectedCategory?.name ?? "Select a category to edit")"),
                    buttons: [
                        .default(Text("Rename")) {
                            if let category = selectedCategory {
                                categoryToRename = category
                                renameCategoryName = category.name
                                showRenameCategory = true
                            }
                        },
                        .destructive(Text("Delete")) {
                            if let category = selectedCategory {
                                categoriesViewModel.deleteCategory(category)
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .alert("Rename Category", isPresented: $showRenameCategory) {
                TextField("Category name", text: $renameCategoryName)
                    .foregroundColor(.primary)
                Button("Cancel", role: .cancel) {
                    renameCategoryName = ""
                    categoryToRename = nil
                }
                Button("Save") {
                    if let category = categoryToRename,
                       !renameCategoryName.isEmpty,
                       !categoriesViewModel.categoryExists(name: renameCategoryName, excluding: category) {
                        categoriesViewModel.renameCategory(category, newName: renameCategoryName)
                        renameCategoryName = ""
                        categoryToRename = nil
                    }
                }
                .disabled(renameCategoryName.isEmpty ||
                          renameCategoryName.count > 24 ||
                          (categoryToRename != nil && categoriesViewModel.categoryExists(name: renameCategoryName, excluding: categoryToRename!)))
            } message: {
                if renameCategoryName.count > 24 {
                    Text("Category name must be 24 characters or less")
                } else if let category = categoryToRename, categoriesViewModel.categoryExists(name: renameCategoryName, excluding: category) {
                    Text("A category with this name already exists")
                }
            }
        }
    }
}

#Preview {
    MainMenuView()
        .modelContainer(for: PlantCategory.self, inMemory: true)
}
