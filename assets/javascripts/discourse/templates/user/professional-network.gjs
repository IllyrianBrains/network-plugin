import ProfessionalNetworkPanel from "../../components/professional-network-panel";

export default <template>
  <div class="user-content professional-network-user-profile" id="user-content">
    <ProfessionalNetworkPanel @outletArgs={{hash model=@controller.model}} />
  </div>
</template>
