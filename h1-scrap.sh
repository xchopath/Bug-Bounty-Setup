#!/usr/bin/env bash
# HackerOne Target Scraper by @xchopath
# Dependencies: apt intall jq curl tee -y
# Run: bash h1-scrap.sh | tee -a h1-scopes.txt

curl -s "https://hackerone.com/directory/programs" -o h1-scrap.init -c h1-scrap.cookie

CSRF_TOKEN="$(cat h1-scrap.init | grep csrf-token | grep -Po 'content="\K.*?(?=")')"

function getScopes() {
	HANDLE_ID="${1}"
	SCOPE_PAGE=0
	while true
	do
		GET_SCOPES=$(curl -s -k -X 'POST' -H "X-Csrf-Token: ${CSRF_TOKEN}" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.97 Safari/537.36' -H 'Content-Type: application/json' -H 'Origin: https://hackerone.com' -H 'Referer: https://hackerone.com/directory/programs' -b h1-scrap.cookie --data "{\"operationName\":\"PolicySearchStructuredScopesQuery\",\"variables\":{\"handle\":\"${HANDLE_ID}\",\"searchString\":\"\",\"eligibleForSubmission\":null,\"eligibleForBounty\":null,\"asmTagIds\":[],\"assetTypes\":[],\"from\":${SCOPE_PAGE},\"size\":100,\"sort\":{\"field\":\"cvss_score\",\"direction\":\"DESC\"},\"product_area\":\"h1_assets\",\"product_feature\":\"policy_scopes\"},\"query\":\"query PolicySearchStructuredScopesQuery(\$handle: String!, \$searchString: String, \$eligibleForSubmission: Boolean, \$eligibleForBounty: Boolean, \$minSeverityScore: SeverityRatingEnum, \$asmTagIds: [Int], \$assetTypes: [StructuredScopeAssetTypeEnum!], \$from: Int, \$size: Int, \$sort: SortInput) {\n  team(handle: \$handle) {\n    id\n    structured_scopes_search(\n      search_string: \$searchString\n      eligible_for_submission: \$eligibleForSubmission\n      eligible_for_bounty: \$eligibleForBounty\n      min_severity_score: \$minSeverityScore\n      asm_tag_ids: \$asmTagIds\n      asset_types: \$assetTypes\n      from: \$from\n      size: \$size\n      sort: \$sort\n    ) {\n      nodes {\n        ... on StructuredScopeDocument {\n          id\n          ...PolicyScopeStructuredScopeDocument\n          __typename\n        }\n        __typename\n      }\n      pageInfo {\n        startCursor\n        hasPreviousPage\n        endCursor\n        hasNextPage\n        __typename\n      }\n      total_count\n      __typename\n    }\n    __typename\n  }\n}\n\nfragment PolicyScopeStructuredScopeDocument on StructuredScopeDocument {\n  id\n  identifier\n  display_name\n  instruction\n  cvss_score\n  eligible_for_bounty\n  eligible_for_submission\n  asm_system_tags\n  created_at\n  updated_at\n  attachments {\n    id\n    file_name\n    file_size\n    content_type\n    expiring_url\n    __typename\n  }\n  __typename\n}\n\"}" "https://hackerone.com/graphql")
		echo "${GET_SCOPES}" | jq -r '.data.team.structured_scopes_search.nodes[] | "\(.identifier) | \(.display_name) | scope:\(.eligible_for_submission) | bounty:\(.eligible_for_bounty)"' | sed "s/^/${HANDLE_ID} | /g"
		if [[ $(echo "${GET_SCOPES}" | jq -r '.data.team.structured_scopes_search.pageInfo.hasNextPage') =~ 'true' ]]; then
			SCOPE_PAGE=$(($SCOPE_PAGE+100))
		else
			break
		fi
	done
}

PAGE="MA=="

while [[ true ]]; do
	LIST_PROGRAM=$(curl -s -k -X 'POST' -H "X-Csrf-Token: ${CSRF_TOKEN}" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.97 Safari/537.36' -H 'Content-Type: application/json' -H 'Origin: https://hackerone.com' -H 'Referer: https://hackerone.com/directory/programs' -b h1-scrap.cookie --data "{\"operationName\":\"DirectoryQuery\",\"variables\":{\"where\":{\"_and\":[{\"_or\":[{\"submission_state\":{\"_eq\":\"open\"}},{\"submission_state\":{\"_eq\":\"api_only\"}},{\"external_program\":{}}]},{\"_not\":{\"external_program\":{}}},{\"_or\":[{\"_and\":[{\"state\":{\"_neq\":\"sandboxed\"}},{\"state\":{\"_neq\":\"soft_launched\"}}]},{\"external_program\":{}}]}]},\"first\":25,\"secureOrderBy\":{\"launched_at\":{\"_direction\":\"DESC\"}},\"product_area\":\"directory\",\"product_feature\":\"programs\", \"cursor\":\"${PAGE}\"},\"query\":\"query DirectoryQuery(\$cursor: String, \$secureOrderBy: FiltersTeamFilterOrder, \$where: FiltersTeamFilterInput) {\n  me {\n    id\n    edit_unclaimed_profiles\n    __typename\n  }\n  teams(first: 25, after: \$cursor, secure_order_by: \$secureOrderBy, where: \$where) {\n    pageInfo {\n      endCursor\n      hasNextPage\n      __typename\n    }\n    edges {\n      node {\n        id\n        bookmarked\n        ...TeamTableResolvedReports\n        ...TeamTableAvatarAndTitle\n        ...TeamTableLaunchDate\n        ...TeamTableMinimumBounty\n        ...TeamTableAverageBounty\n        ...BookmarkTeam\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n\nfragment TeamTableResolvedReports on Team {\n  id\n  resolved_report_count\n  __typename\n}\n\nfragment TeamTableAvatarAndTitle on Team {\n  id\n  profile_picture(size: medium)\n  name\n  handle\n  submission_state\n  triage_active\n  publicly_visible_retesting\n  state\n  allows_bounty_splitting\n  external_program {\n    id\n    __typename\n  }\n  ...TeamLinkWithMiniProfile\n  __typename\n}\n\nfragment TeamLinkWithMiniProfile on Team {\n  id\n  handle\n  name\n  __typename\n}\n\nfragment TeamTableLaunchDate on Team {\n  id\n  launched_at\n  __typename\n}\n\nfragment TeamTableMinimumBounty on Team {\n  id\n  currency\n  base_bounty\n  __typename\n}\n\nfragment TeamTableAverageBounty on Team {\n  id\n  currency\n  average_bounty_lower_amount\n  average_bounty_upper_amount\n  __typename\n}\n\nfragment BookmarkTeam on Team {\n  id\n  bookmarked\n  __typename\n}\n\"}" "https://hackerone.com/graphql")
	for handle_id in $(echo "${LIST_PROGRAM}" | jq -r '.data.teams.edges[].node.handle')
	do
		getScopes "${handle_id}"
	done
	PAGE=$(echo "${LIST_PROGRAM}" | jq -r '.data.teams.pageInfo.endCursor' 2> /dev/null)
	if [[ -z ${PAGE} ]]; then
		break
	fi
done
