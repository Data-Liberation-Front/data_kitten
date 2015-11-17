module CKANFakeweb

  module_function
  def register_defence_dataset
    data = {
      body: load_fixture("ckan/rest-dataset-defence.json"),
      content_type: "application/json"
    }
    register_urls(URI("http://example.org/"), {
      "/dataset/defence" => {
        :body => "",
        :content_type => "text/html"
      },
      "/api/3/action/package_show?id=defence" => {
        :body => "",
        :content_type => "application/json"
      },
      "/api/2/rest/dataset/defence" => data,
      "/api/2/search/dataset?q=defence" => data,
      "/api/rest/package/47f7438a-506d-49c9-b565-7573f8df031e" => data,
      "/api/rest/package/defence" => data,
      "/api/rest/group/a3969e37-3ac3-42fe-8317-c8575a9f5317" => {
        :body => load_fixture("ckan/rest-organization-defence.json"),
        :content_type => "application/json"
      }
    })
  end

  def register_toilets_dataset
    html = {
      body: "",
      content_type: "text/html"
    }
    data = {
      body: load_fixture("ckan/rest-dataset-toilets.json"),
      content_type: "application/json"
    }
    register_urls(URI("http://example.org/"), {
      "/dataset/toilets" => html,
      "/dataset/62766308-cb4f-4275-b4a4-937f52a978c5" => html,
      "/api/3/action/package_show?id=toilets" => {
        :body => load_fixture("ckan/package_show-toilets.json"),
        :content_type => "application/json"
      },
      "/api/2/rest/dataset/toilets" => data,
      "/api/2/search/dataset?q=toilets" => data,
      "/api/rest/package/553b3049-2b8b-46a2-95e6-640d7986a8c1" => data,
      "/api/rest/package/62766308-cb4f-4275-b4a4-937f52a978c5" => data,
      "/api/rest/package/toilets" => data,
      "/api/rest/group/2df7090e-2ebb-416e-8994-6de43d820d5c" => {
        :body => load_fixture("ckan/rest-organization-health.json"),
        :content_type => "application/json"
      },
    })
  end


  def register_cadastral_dataset
    register_urls(URI("http://example.org/"), {
      "/api/rest/package/65493c4b-46d5-4125-b7d4-fc1df2b33349" => {
        :body => load_fixture("ckan/rest-dataset-cadastral.json"),
        :content_type => "application/json"
      },
      "/api/3/action/organization_show?id=cd937140-1310-4e2a-b211-5de8bebd910d" => {
        :body => load_fixture("ckan/organization_show-ni-spatial.json"),
        :content_type => "application/json"
      }
    })
  end

  def register_pollinator_dataset
    register_urls(URI("http://example.org/"), {
      "/api/rest/package/10d394fd-88b9-489f-9552-b7b567f927e2" => {
        :body => load_fixture("ckan/rest-dataset-pollinator.json"),
        :content_type => "application/json"
      },
      "/api/3/action/organization_show?id=866f4088-ae4f-43b8-ba8c-6d3141a327f2" => {
        :body => load_fixture("ckan/organization_show-ecology.json"),
        :content_type => "application/json"
      }
    })
  end

  def register_frozen_animals_dataset
    register_urls(URI("http://example.org"), {
      "/api/3/action/package_show?id=frozen-animals" => {
        :body => load_fixture("ckan/package-show-frozen-animals.json"),
        :content_type => "application/json"
      },
      "/api/3/action/organization_show?id=e70862ec-8167-48e6-a27c-a0e9db1ebc87" => {
        :body => load_fixture("ckan/organization-show-peterborough.json"),
        :content_type => "application/json"
      }
    })
  end

  def register_dataset(base_uri, name, fixture)
    data = {
      body: fixture, content_type: "application/json"
    }
    {
      "dataset/#{name}" => {
        :body => "",
        :content_type => "text/html"
      },
      "api/3/action/package_show?id=#{name}" => {
        :body => "",
        :content_type => "application/json"
      },
      "api/2/rest/dataset/#{name}" => data,
      "api/2/search/dataset?q=#{name}" => data,
      "api/rest/package/#{name}" => data,
      "api/rest/package/#{fixture['id']}" => data
    }.each do |path, options|
      FakeWeb.register_uri(:get, (base_uri + path).to_s, options)
    end

    return (base_uri + "dataset/#{name}").to_s
  end

  def register_urls(base_uri, urls)
    urls.each do |path, options|
      FakeWeb.register_uri(:get, base_uri + path, options)
    end
  end

end
